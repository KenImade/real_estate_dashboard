from pathlib import Path
import pandas as pd
import sys

def clean_data(input_path:str, output_path:str):
    """
    Processes the data from the UK Land Registry website.

    Parameters:
    input_path (str): The path to the raw data downloaded.
    output_path (str): The path to the saved processed data.

    Returns:
    None

    Raises:
    Prints an error if it can't read the file.
    """
    input_path = Path(input_path)
    output_path = Path(output_path)
    output_path.mkdir(parents=True, exist_ok=True)  # Ensure output directory exists before looping through files

    for file in input_path.glob('*.csv'):
        print(f"Processing {file}")
        try:
            df = pd.read_csv(
                file,  # You can pass a Path object directly to read_csv
                header=None,
                names=[
                    "transaction_unique_identifier", "price", "date_of_transfer", "postcode", "property_type",
                    "old_new", "duration", "paon", "saon", "street", "locality", "town_or_city",
                    "district", "county", "ppd_category_type", "record_status"
                ],
                dtype={
                    'transaction_unique_identifier': 'str',
                    'price': 'float64',
                    'postcode': 'str',
                    'property_type': 'str',
                    'old_new': 'str',
                    'duration': 'str',
                    'paon': 'str',
                    'saon': 'str',
                    'street': 'str',
                    'locality': 'str',
                    'town_or_city': 'str',
                    'district': 'str',
                    'county': 'str'
                },
                parse_dates=['date_of_transfer'],  # Ensures dates are parsed
                date_parser=lambda x: pd.to_datetime(x, format='%Y-%m-%d %H:%M')
            )
        except Exception as e:
            print(f"Failed to read {file}: {e}")
            continue

        # Set update column to Y or N if file is monthly update
        if file.name == "pp-monthly-update-new-version.csv":
            df['is_update'] = 'Y'
        else:
            df['is_update'] = 'N'

        # Create Postcode Outward column
        df['postcode_outward_code'] = (df['postcode'].apply(lambda x: str(x).split()[0] 
                                                            if pd.notna(x) and ' ' in str(x) else x))

        # Date conversion
        # Filling missing date with placeholder value
        df['date_of_transfer'].fillna('1900-01-01', inplace=True) 

        # Standardize date format
        df['date_of_transfer'] = pd.to_datetime(df['date_of_transfer']).dt.strftime('%Y-%m-%d')

        # Drop irrelevant columns
        df.drop(columns=["ppd_category_type", "record_status"], inplace=True)

        # Set text to title case
        columns_to_capitalize = ["paon", "saon", "street", "locality", "town_or_city", "district", "county"]
        df[columns_to_capitalize] = df[columns_to_capitalize].apply(lambda x: x.str.title())

        # Use file.stem to get the base name of the file without the extension for output file naming
        df.to_parquet(output_path / f"{file.stem}.parquet", index=False)
        print(f"Processing for {file} complete")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_path> <output_path>")
        sys.exit(1)
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    clean_data(input_path, output_path)