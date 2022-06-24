function c = select_table_fields(config, t)

tsf = TableFieldSelection();
tsf.metanames = config.metanames;
if isfield(config, "default_selection")
    tsf.default_selection = config.default_selection;
end
c = tsf.select(t);

% % OUTPUT PREPARATIONS
% c = [];
% 
% % CALLBACKS
%     function done_fcn(varargin)
%         out_columns = string(meta.Data);
%         c = containers.Map(metanames, out_columns);
%         delete(f);
%     end
% 
%     function cancel_fcn(varargin)
%         delete(f);
%     end
% 
%     function cell_edit_fcn(src, ~)
%         selected = meta.Data;
%         available_cols = setdiff(cols, selected, "stable");
%         available_cols = cellstr(available_cols);
%         src.ColumnFormat = {available_cols};
%         
%         update_done()
%     end
% 
%     function update_done()
%         data = meta.Data();
%         all_selected = all(data ~= default_selection);
%         all_unique = isempty(setdiff(data, unique(data)));
%         if all_selected && all_unique
%             done.Enable = true;
%         else
%             done.Enable = false;
%         end
%     end
% 
% % WINDOW ARRANGEMENT DEFINITIONS
% FIGURE_X = 50;
% FIGURE_Y = 50;
% FIGURE_H = 480;
% FIGURE_W = 960;
% GUTTER = 10;
% BUTTON_W = 96;
% BUTTON_H = 26;
% META_W_FRAC = 0.3;
% PRE_W_FRAC = 1.0 - META_W_FRAC;
% 
% % FIGURE
% f = uifigure();
% f.CloseRequestFcn = @cancel_fcn;
% f.Position = [FIGURE_X FIGURE_Y FIGURE_W FIGURE_H];
% f.Resize = "off";
% f.Visible = false;
% 
% % METANAME ASSIGNMENT TABLE
% meta = uitable(f);
% meta.CellEditCallback = @cell_edit_fcn;
% meta.ColumnEditable = true;
% meta.ColumnFormat = {cellstr(cols)}; % need callback to deal with multiple selections
% meta.ColumnName = [];
% meta.ColumnSortable = false;
% meta.Data = repmat(default_selection, numel(metanames), 1);
% meta_x = GUTTER;
% meta_y = BUTTON_H + 2 * GUTTER;
% meta_w = round(FIGURE_W * META_W_FRAC) - GUTTER;
% meta_h = FIGURE_H - 3 * GUTTER - BUTTON_H;
% meta.Position = [meta_x meta_y meta_w meta_h];
% meta.RowName = metanames;
% 
% % USER DATA PREVIEW TABLE
% pre = uitable(f);
% pre.Data = head(t, 100);
% pre.ColumnEditable = false(1, width(t));
% pre.Parent = f;
% pre_x = meta_w + 2 * GUTTER;
% pre_y = BUTTON_H + 2 * GUTTER;
% pre_w = round(FIGURE_W * PRE_W_FRAC) - 2 * GUTTER;
% pre_h = FIGURE_H - 3 * GUTTER - BUTTON_H;
% pre.Position = [pre_x pre_y pre_w pre_h];
% 
% % CANCEL BUTTON
% cancel = uibutton(f);
% cancel.ButtonPushedFcn = @cancel_fcn;
% cancel_x = GUTTER;
% cancel_y = GUTTER;
% cancel_w = BUTTON_W;
% cancel_h = BUTTON_H;
% cancel.Position = [cancel_x cancel_y cancel_w cancel_h];
% cancel.Text = "Cancel";
% 
% % DONE BUTTON
% done = uibutton(f);
% done.ButtonPushedFcn = @done_fcn;
% done_w = BUTTON_W;
% done_h = BUTTON_H;
% done_x = FIGURE_W - GUTTER - done_w;
% done_y = GUTTER;
% done.Position = [done_x done_y done_w done_h];
% done.Text = "Done";
% update_done();
% 
% % FINAL PREPARATIONS
% f.Visible = true;
% uiwait(f);

end

