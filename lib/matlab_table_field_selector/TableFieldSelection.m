classdef TableFieldSelection < handle
    properties
        % required
        metanames(:,1) string
        
        % optional
        default_selection(:,1) string = "Double click here to select..."
        metaname_table_width_fraction(1,1) double {mustBeFinite,mustBeReal,mustBeNonnegative,mustBeLessThanOrEqual(metaname_table_width_fraction,1.0)} = 0.5
    end
    
    methods
        function obj = TableFieldSelection()
            obj.metanames_to_fields = containers.Map();
            
            f = obj.build_figure();
            cb = obj.build_cancel_button(f);
            db = obj.build_done_button(f);
            [mt, left_w] = obj.build_metaname_table(f);
            pt = obj.build_preview_table(f, left_w);
            
            obj.figure_handle = f;
            obj.cancel_button_handle = cb;
            obj.done_button_handle = db;
            obj.metaname_table_handle = mt;
            obj.preview_table_handle = pt;
        end
        
        function c = select(obj, t)
            assert(0 < numel(obj.metanames));
            
            cols = string(t.Properties.VariableNames);
            if ~isempty(intersect(cols, obj.default_selection))
                error(...
                    "TableFieldSelection:DefaultInTable", ...
                    "table must not contain default_selection as a field"...
                    );
            end
            if numel(cols) < numel(obj.metanames)
                error(...
                    "TableFieldSelection:NotEnoughFields", ...
                    "table does not have enough fields (%d of %d required)", ...
                    numel(cols), numel(obj.metanames)...
                    );
            end
            
            obj.update_done_button();
            obj.update_metaname_table(t);
            obj.update_preview_table(t);
            obj.figure_handle.Visible = true;
            
            uiwait(obj.figure_handle);
            
            if obj.done
                c = obj.metanames_to_fields;
            else
                c = [];
            end
        end
    end
    
    properties (Access = private)
        done(1,1) logical = false
        metanames_to_fields containers.Map
        
        figure_handle matlab.ui.Figure
        cancel_button_handle matlab.ui.control.Button
        done_button_handle matlab.ui.control.Button
        metaname_table_handle matlab.ui.control.Table
        preview_table_handle matlab.ui.control.Table
    end
    
    properties (Access = private, Constant)
        FIGURE_X = 50;
        FIGURE_Y = 50;
        FIGURE_W = 960;
        FIGURE_H = 480;
        GUTTER = 6;
        BUTTON_W = 96;
        BUTTON_H = 26;
    end
    
    methods (Access = private)
        function b = build_cancel_button(obj, f)
            b = uibutton(f);
            b.ButtonPushedFcn = @(varargin)obj.cancel_button_ButtonPushedFcn(varargin{:});
            b.Text = "Cancel";
            
            x = obj.GUTTER;
            y = obj.GUTTER;
            w = obj.BUTTON_W;
            h = obj.BUTTON_H;
            b.Position = [x y w h];
        end
        
        function b = build_done_button(obj, f)
            b = uibutton(f);
            b.ButtonPushedFcn = @(varargin)obj.done_button_ButtonPushedFcn(varargin{:});
            b.Text = "Done";
            
            w = obj.BUTTON_W;
            h = obj.BUTTON_H;
            x = obj.FIGURE_W - obj.GUTTER - w;
            y = obj.GUTTER;
            b.Position = [x y w h];
        end
        
        function f = build_figure(obj)
            f = uifigure();
            f.CloseRequestFcn = @(varargin)obj.figure_CloseRequestFcn(varargin{:});
            f.Name = "Column selection";
            f.Resize = false;
            f.Visible = false;
            
            x = obj.FIGURE_X;
            y = obj.FIGURE_Y;
            w = obj.FIGURE_W;
            h = obj.FIGURE_H;
            f.Position = [x y w h];
        end
        
        function [t, w] = build_metaname_table(obj, f)
            t = uitable(f);
            t.ColumnEditable = true;
            t.ColumnName = "Double click to select below";
            t.ColumnSortable = false;
            
            x = obj.GUTTER;
            y = obj.BUTTON_H + 2 * obj.GUTTER;
            w = round(obj.FIGURE_W * obj.metaname_table_width_fraction) - obj.GUTTER;
            h = obj.FIGURE_H - 3 * obj.GUTTER - obj.BUTTON_H;
            t.Position = [x y w h];
        end
        
        function [t, w] = build_preview_table(obj, f, left_w)
            t = uitable(f);
            
            PRE_W_FRAC = 1.0 - obj.metaname_table_width_fraction;
            x = left_w + 2 * obj.GUTTER;
            y = obj.BUTTON_H + 2 * obj.GUTTER;
            w = round(obj.FIGURE_W * PRE_W_FRAC) - 2 * obj.GUTTER;
            h = obj.FIGURE_H - 3 * obj.GUTTER - obj.BUTTON_H;
            t.Position = [x y w h];
        end
        
        function data = get_selections(obj)
            data = obj.metaname_table_handle.Data;
        end
        
        function update_done_button(obj)
            data = obj.metaname_table_handle.Data;
            enable = ~isempty(data) ...
                && all(data ~= obj.default_selection) ...
                && isempty(setdiff(data, unique(data)));
            obj.done_button_handle.Enable = enable;
        end
        
        function update_metaname_table(obj, t)
            fields = t.Properties.VariableNames;
            fields = [obj.default_selection fields];
            obj.metaname_table_handle.CellEditCallback = @(varargin)obj.metaname_table_CellEditCallback(fields, varargin{:});
            obj.metaname_table_handle.ColumnFormat = {cellstr(fields)};
            obj.metaname_table_handle.Data = repmat(obj.default_selection, numel(obj.metanames), 1);
            obj.metaname_table_handle.RowName = obj.metanames;
        end
        
        function update_preview_table(obj, t)
            obj.preview_table_handle.Data = head(t, 100);
            obj.preview_table_handle.ColumnEditable = false(1, width(t));
        end
    end
    
    methods (Access = private) % CALLBACKS
        function cancel_button_ButtonPushedFcn(obj, ~, ~)
            obj.done = false;
            obj.figure_handle.Visible = false;
            uiresume(obj.figure_handle);
        end
        
        function done_button_ButtonPushedFcn(obj, ~, ~)
            obj.metanames_to_fields = containers.Map(obj.metanames, obj.get_selections());
            obj.done = true;
            obj.figure_handle.Visible = false;
            uiresume(obj.figure_handle);
        end
        
        function figure_CloseRequestFcn(obj, ~, ~)
            obj.done = false;
            obj.figure_handle.Visible = false;
            uiresume(obj.figure_handle);
        end
        
        function metaname_table_CellEditCallback(obj, fields, src, ~)
            selected = obj.get_selections();
            available_cols = setdiff(fields, selected, "stable");
            available_cols = [obj.default_selection available_cols];
            available_cols = cellstr(available_cols);
            src.ColumnFormat = {available_cols};

            obj.update_done_button();
        end
    end
end