#!/usr/bin/env python

# make sure to install these packages before running:
# pip install pandas
# pip install sodapy

import pandas as pd
from sodapy import Socrata

# Unauthenticated client only works with public data sets. Note 'None'
# in place of application token, and no username or password:
client = Socrata("data.cityofchicago.org", None)


# Todos los crímenes de Chicago desde 2020 hasta 2025
results_2020 = client.get_all("ijzp-q8t2", where="year = 2020")

results_2021 = client.get_all("ijzp-q8t2", where="year = 2021")

results_2022 = client.get_all("ijzp-q8t2", where="year = 2022")

results_2023 = client.get_all("ijzp-q8t2", where="year = 2023")

results_2024 = client.get_all("ijzp-q8t2", where="year = 2024")

results_2025 = client.get_all("ijzp-q8t2", where="year = 2025")

df_2020 = pd.DataFrame.from_records(results_2020)
df_2021 = pd.DataFrame.from_records(results_2021)
df_2022 = pd.DataFrame.from_records(results_2022)
df_2023 = pd.DataFrame.from_records(results_2023)
df_2024 = pd.DataFrame.from_records(results_2024)
df_2025 = pd.DataFrame.from_records(results_2025)

results_df = pd.concat([df_2020, df_2021, df_2022, df_2023, df_2024, df_2025], ignore_index=True)


results_df.to_csv("chicago_crime_2020-2025.csv", index=False)