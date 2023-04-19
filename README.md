# easy_localization_sheet
Download the csv file and generate json files for [easy_localization](https://pub.dev/packages/easy_localization) or any package that supports localization from json

### Installation
Add to your `pubspec.yaml`:
`dart pub add --dev easy_localization_sheet` or `dart pub add --dev easy_localization_sheet`
Your `pubspec.yaml` will look like below:
```
dependencies:
    ...
dev_dependencies:
    ...
    easy_localization_sheet: <last_version>
```
### Usage
Add below section to your `pubspec.yaml`
```
easy_localization_sheet:
    csv_url: 'your url'
    output_dir: 'assets/translations' # Optional, default is assets
```

Then run `dart run easy_localization_sheet` or `flutter pub run easy_localization_sheet`
*** This package generates json files only. Let your localization package do the rest with `output_dir`***
### Example
[Example sheet available here](https://docs.google.com/spreadsheets/d/1p6oQw6BKObb3RU_fIWskJjofRzEb01cfzfNE14Px4nw/edit#gid=0)
![csv example file](/images/sheet_screenshot.png)


### Syntax
- `key` column is required, row contains `key` also called header.
- Rows above header will be ignored
- Ignore column should be put into `()`, example `(your column name)`
- Nested keys
```
# key name
gender.male
gender.female
```
```
# generated json
"gender": {
    "male": "Male",
    "female": "Female"
}
```
Visit example sheet for more detail.