import pandas as pd
import streamlit as st
import matplotlib.pyplot as plt


st.set_page_config(page_title="Dancing Task Data Explorer", layout="wide")

st.title("Dancing Task Data Explorer")
#st.caption("Step 1: load the dataset and preview it.")

st.sidebar.title("Options")

@st.cache_data
def load_csv_from_path(path: str) -> pd.DataFrame:
    df = pd.read_csv(path)
    return df

filename = "data/dancing_task_anonymized.csv"
df = load_csv_from_path(filename)
df["move_number"] = pd.to_numeric(df["move_number"])
st.write(df.head())

min_moves = st.sidebar.slider(
    "Minimum moves per trial",
    min_value=1,
    max_value=int(df.groupby("trial_index").size().max()),
    value=1
)
max_moves = st.sidebar.slider(
    "Maximum moves per trial",
    min_value=min_moves,
    max_value=int(df.groupby("trial_index").size().max()),
    value=int(df.groupby("trial_index").size().max())
)

valid_trials = (
    df.groupby("trial_index")
    .filter(lambda x: len(x) >= min_moves and len(x) <= max_moves)
)




fig, ax = plt.subplots(figsize=(6, 4))

for trial_id, df_trial in valid_trials.groupby("trial_index"):
    df_trial = df_trial.sort_values("move_number")
    ax.plot(
        df_trial["move_number"],
        df_trial["distance_before_move"]
    )

ax.set_xlabel("move_number")
ax.set_ylabel("distance_before_move")

st.pyplot(fig, use_container_width=False)
