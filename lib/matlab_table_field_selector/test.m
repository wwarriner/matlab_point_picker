%% WORKS
t = readtable("res/data.csv");
config.metanames = ["x", "y"];
c = select_table_fields(config, t);
if isempty(c)
    fprintf("canceled" + newline);
else
    fprintf("keys:   "); disp(c.keys());
    fprintf("values: "); disp(c.values());
end

%% EMITS ERROR: not enough fields
t = readtable("res/empty.csv");
c = select_table_fields(config, t);
