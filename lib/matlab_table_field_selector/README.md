# MATLAB Table Field Selector
A configurable UI enabling your users to select which fields in a table are relevant to your application. For the purposes of this documentation, the fields your application needs are called "metanames". Fields your users provide are just called "fields".

## Operation
Call `select(config, t)` on the user table `t` and a config `struct`. A modal `uifigure` will be created waiting for the user to finish selections. The return value will be a `containers.Map` object whose keys are your metanames and whose values are the user's fields. If the user clicks "Cancel" or closes the `uifigure` without clicking "Done" an empty array will be returned.

### Configuration
To configure, create a config `struct` with the following fields.
- `metanames` - A list of names suitable for display. The user will select fields to match these.
- `default_selection` - The default selection value for metanames. Must be a scalar string.

## User Guide
For each field on the left table, please use the table drop-downs to select columns from the table preview on the right. Double click in the left-hand table cells to change them. To exit early, click "Cancel" or close the window. To finish click "Done". The "Done" button will only highlight once all cells have been filled.
