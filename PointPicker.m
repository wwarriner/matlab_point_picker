classdef PointPicker < handle
    methods
        function app = PointPicker()
            extend_search_path();

            fh = uifigure();
            fh.Position = [50 50 1200 800];
            fh.Resize = "off";
            fh.Name = app.FIGURE_BASE_NAME;
            app.fh = fh;

            axh = uiaxes(fh);
            axh.Position = [0, 60, fh.Position(3), fh.Position(4) - 60];
            axh.ButtonDownFcn = @app.select_peak;
            app.axh = axh;

            hold(axh, "on");
            app.signal_ph = plot(axh, 0, 0);
            app.signal_ph.Visible = false;
            app.signal_ph.Marker = "none";
            app.signal_ph.Color = [0.0, 0.0, 1.0];

            app.peak_ph = plot(axh, 0, 0);
            app.peak_ph.Visible = false;
            app.peak_ph.Marker = "+";
            app.peak_ph.MarkerSize = 8;
            app.peak_ph.Color = [1.0, 0.0, 0.0];
            app.peak_ph.LineStyle = "none";
            hold(axh, "off");

            loadb = uibutton(fh);
            loadb.Position = [6, 6, 120, 26];
            loadb.Text = "Load Folder...";
            loadb.ButtonPushedFcn = @app.load_folder;
            app.load_folder_button = loadb;

            plottypeb = uiswitch(fh);
            plottypeb.Position = [6 + 168 + 6, 6, 120, 26]; % 168 is fuzzy
            plottypeb.Items = ["Series", "Scatter"];
            plottypeb.ValueChangedFcn = @app.change_plot_type;
            app.plot_type_button = plottypeb;

            helpb = uibutton(fh);
            helpb.Position = [6 + 120 + 160 + 2*6, 6, 80, 26];
            helpb.Text = "Help!";
            helpb.ButtonPushedFcn = @app.show_help;
            app.help_button = helpb;

            clearb = uibutton(fh);
            clearb.Position = [6 + 120 + 160 + 80 + 3*6 + 24, 6, 80, 26];
            clearb.Text = "Clear Data...";
            clearb.ButtonPushedFcn = @app.clear_data;
            clearb.BackgroundColor = [1.00, 0.80, 0.80];
            app.clear_data_button = clearb;

            prevb = uibutton(fh);
            prevb.Position = [fh.Position(3) - 6 - 3*120 - 2*6, 6, 120, 26];
            prevb.Text = "<- Previous";
            prevb.ButtonPushedFcn = @app.read_previous;
            app.previous_button = prevb;

            filecountlab = uilabel(fh);
            filecountlab.Position = [fh.Position(3) - 6 - 2*120 - 6, 6, 120, 26];
            filecountlab.Text = "No Files Loaded";
            filecountlab.HorizontalAlignment = "right";
            app.file_count_label = filecountlab;

            nextb = uibutton(fh);
            nextb.Position = [fh.Position(3) - 120 - 6, 6, 120, 26];
            nextb.Text = "Next ->";
            nextb.ButtonPushedFcn = @app.read_next;
            app.next_button = nextb;

            app.update_figure_name();
            app.update_clear_data_button();
            app.update_navigation_controls();
        end

        function load_folder(app, ~, ~)
            path = uigetdir(app.folder_path);
            if ~path
                return;
            end

            f = get_contents(path);
            f = get_files_with_extension(f, ".csv");
            f = get_full_paths(f);
            if numel(f) <= 0
                warning("No csv files found in %s", path);
                return;
            end

            app.folder_path = path;
            app.files = f;
            app.file_count = numel(f);
            app.file_index = 1;

            app.pick_columns();
            app.read_current();

            app.update_figure_name();
            app.update_clear_data_button();
            app.update_navigation_controls();
        end

        function change_plot_type(app, ~, event)
            if event.Value == "Series"
                line_style = "-";
                marker = "none";
                marker_face_color = "none";
            elseif event.Value == "Scatter"
                line_style = "none";
                marker = "o";
                marker_face_color = [0.6 1.0 1.0];
            else
                assert(false);
            end
            app.signal_ph.LineStyle = line_style;
            app.signal_ph.Marker = marker;
            app.signal_ph.MarkerFaceColor = marker_face_color;
        end

        function show_help(app, ~, ~)
            MESSAGE = [...
                "1) Load Folder", ...
                "2) Pick Columns", ...
                "3) Pick Points", ...
                "Left click near a point to select it.", ...
                "Right click near a point to unselect it.", ...
                "Saving occurs automatically with each change.", ...
                "Click Next to move to a new plot.", ...
                "Previous moves to a seen plot." ...
                ];
            uialert(app.fh, MESSAGE, "Help", "icon", "info")
        end

        function clear_data(app, ~, ~)
            reply = uiconfirm(...
                app.fh, ...
                ["Really clear all data?", "This cannot be undone."], ...
                "Clear All Data", ...
                "options", ["Clear Data", "Go Back"], ...
                "defaultoption", "Go Back", ...
                "canceloption", "Go Back" ...
                );
            if reply == "Go Back"
                return;
            end

            app.folder_path = "";
            app.files = [];
            app.file_count = 0;
            app.file_index = 0;
            app.loaded_table = table();
            app.xaxis_field = "";
            app.yaxis_field = "";
            app.signal_ph.Visible = false;
            app.peak_ph.Visible = false;

            app.update_figure_name();
            app.update_clear_data_button();
            app.update_navigation_controls();
        end

        function read_next(app, ~, ~)
            assert(app.check_files_are_loaded());
            app.file_index = app.file_index + 1;
            app.read_current();
            app.update_figure_name();
            app.update_navigation_controls();
        end

        function read_previous(app, ~, ~)
            assert(app.check_files_are_loaded());
            app.file_index = app.file_index - 1;
            app.read_current();
            app.update_figure_name();
            app.update_navigation_controls();
        end

        function select_peak(app, ~, event)
            if isempty(app.loaded_table)
                return;
            end

            if app.fh.SelectionType == "normal"
                type = "add";
            elseif app.fh.SelectionType == "alt"
                type = "remove";
            else
                return;
            end

            aspect_ratio = app.axh.DataAspectRatio(1:2);

            scaled = app.loaded_table{:, 1:2};
            scaled = scaled ./ aspect_ratio;

            picked = event.IntersectionPoint(1:2);
            picked = picked ./ aspect_ratio;

            [inds, distance] = dsearchn(scaled, picked);
            r = [diff(app.axh.XLim), diff(app.axh.YLim)];
            if min(r, [], "all") * 0.1 < distance(1) 
                return;
            end

            app.update_current(inds(1), type)
        end

        function read_current(app)
            app.loaded_table = load_current_table(app);

            if ~ismember(app.IS_PICKED_FIELD, app.loaded_table.Properties.VariableNames)
                peak_field_values = false([height(app.loaded_table), 1]);
            else
                peak_field_values = logical(app.loaded_table.(app.IS_PICKED_FIELD));
            end
            app.loaded_table.(app.IS_PICKED_FIELD) = peak_field_values;

            app.signal_ph.XData = app.loaded_table.(app.xaxis_field);
            app.signal_ph.YData = app.loaded_table.(app.yaxis_field);
            app.signal_ph.Visible = true;

            app.peak_ph.XData = app.loaded_table.(app.xaxis_field);

            peak_y = nan([height(app.loaded_table), 1]);
            keep = app.loaded_table.(app.IS_PICKED_FIELD);
            y = app.loaded_table.(app.yaxis_field);
            peak_y(keep) = y(keep);
            app.peak_ph.YData = peak_y;

            app.peak_ph.Visible = true;
        end

        function t = load_current_table(app)
            t = readtable(app.files(app.file_index));
        end

        function n = get_current_file_name(app)
            [~, n, ~] = fileparts(app.files(app.file_index));
        end

        function write_current(app)
            writetable(app.loaded_table, app.files(app.file_index));
        end

        function update_current(app, index, type)
            if type == "add"
                is_picked = true;
                peak_y = app.loaded_table{index, 2};
            elseif type == "remove"
                is_picked = false;
                peak_y = nan;
            else
                assert(False);
            end
            app.loaded_table.(app.IS_PICKED_FIELD)(index) = is_picked;
            app.peak_ph.YData(index) = peak_y;
            drawnow();
            write_current(app);
        end

        function c = pick_columns(app)
            config.metanames = ["X Axis", "Y Axis"];
            test_table = app.load_current_table();
            c = select_table_fields(config, test_table);
            app.xaxis_field = c(config.metanames(1));
            app.yaxis_field = c(config.metanames(2));
        end

        function update_figure_name(app)
            if app.check_files_are_loaded()
                file_name = app.get_current_file_name();
                name = sprintf("%s: %s", app.FIGURE_BASE_NAME, file_name);
            else
                name = app.FIGURE_BASE_NAME;
            end
            app.fh.Name = name;
        end

        function update_clear_data_button(app)
            app.clear_data_button.Enable = ~isempty(app.files);
        end

        function result = check_files_are_loaded(app)
            result = 0 < app.file_count;
        end

        function update_navigation_controls(app)
            assert(app.file_index <= app.file_count);

            are_columns_picked = app.xaxis_field ~= "" && app.yaxis_field ~= "";

            are_files_loaded = app.check_files_are_loaded();
            if are_files_loaded
                label = sprintf("%i / %i", app.file_index, app.file_count);
            else
                label = "No Files Loaded";
            end
            app.file_count_label.Text = label;

            at_start = app.file_index == 1;
            app.previous_button.Enable = ~at_start && are_files_loaded && are_columns_picked;

            at_end = app.file_index == app.file_count;
            app.next_button.Enable = ~at_end && are_files_loaded && are_columns_picked;
        end
    end

    properties
        fh matlab.ui.Figure
        axh matlab.ui.control.UIAxes
        signal_ph matlab.graphics.chart.primitive.Line
        peak_ph matlab.graphics.chart.primitive.Line
        load_folder_button matlab.ui.control.Button
        clear_data_button matlab.ui.control.Button
        plot_type_button matlab.ui.control.Switch
        help_button matlab.ui.control.Button
        previous_button matlab.ui.control.Button
        next_button matlab.ui.control.Button
        file_count_label matlab.ui.control.Label

        folder_path (1,1) string = ""
        files (:,1) string
        file_count (1,1) double {mustBeReal,mustBeFinite,mustBeNonnegative} = 0
        file_index (1,1) double {mustBeReal,mustBeFinite,mustBeNonnegative} = 0

        loaded_table table
        xaxis_field (1,1) string = ""
        yaxis_field (1,1) string = ""
    end

    properties (Constant)
        FIGURE_BASE_NAME = "Point Picker";
        IS_PICKED_FIELD (1,1) string = "IS_PICKED__";
    end
end

