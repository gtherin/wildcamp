import gspread
import pandas as pd
import numpy as np
import json

import unicodedata

# Imports the Google Cloud client library
from google.cloud import storage
from google.cloud import firestore


def remove_accents(input_str):
    nfkd_form = unicodedata.normalize("NFKD", input_str)
    only_ascii = nfkd_form.encode("ASCII", "ignore")
    return only_ascii.decode("ascii").lower().replace(" ", "_")


def get_sheet():

    from oauth2client.service_account import ServiceAccountCredentials

    google_credentials = ServiceAccountCredentials.from_json_keyfile_name(
        "lib/keys.json",
        [
            "https://spreadsheets.google.com/feeds",
            "https://www.googleapis.com/auth/drive",
        ],
    )
    gc = gspread.authorize(google_credentials)
    sheets = gc.open_by_url("https://docs.google.com/spreadsheets/d/1u7UTe7a4IV48dzaHTAjns4GbGnmqDex_KeOWKWF-ROA")

    data = sheets.worksheet("Réponses au formulaire 1").get_all_values()

    data = pd.DataFrame(np.array(data))
    data.columns = data.iloc[0]
    data = data[1:]

    data.columns = [
        "timestamp",
        "provider",
        "name",
        "zone",
        "lat",
        "lng",
        "stars",
        "resources",
        "isolation",
        "comment",
        "files",
    ]

    data["wood"] = data["resources"].fillna("").str.contains("Bois").astype(int)
    data["water"] = data["resources"].fillna("").str.contains("Eau").astype(int)
    data["lat"] = data["lat"].astype(float)
    data["lng"] = data["lng"].astype(float)

    data["pinType"] = "assets/pin" + data["stars"] + ".png"
    cover_photos = ["1", "2", "3", "4", "5", "", "7", "", "9", "10", "11", "", ""]
    data["coverImage"] = [
        f"assets/pictures/Camp{p} - guillaume therin.jpg" if p != "" else "assets/white.jpg" for p in cover_photos
    ]
    data["id"] = [remove_accents(data["name"][d]) for d in data.index]

    data = data[
        ["id", "name", "lat", "lng", "zone", "comment", "pinType", "coverImage", "stars", "isolation", "wood", "water"]
    ]

    return data


if __name__ == "__main__":
    # execute only if run as a script

    df = get_sheet()

    if 1:
        output = []

        for d in df.index:
            output.append(df.loc[d].to_dict())

        with open("assets/wild_camping_sites.json", "w") as outfile:
            json.dump(output, outfile)

    if 1:
        # export GOOGLE_APPLICATION_CREDENTIALS="/home/guydegnol/projects/service-account-file.json"
        # $env:GOOGLE_APPLICATION_CREDENTIALS="C:\Users\gt\projects\wildcamp\lib\data\wildcamping-python.json"
        # set GOOGLE_APPLICATION_CREDENTIALS="C:\Users\gt\projects\wildcamp\lib\data\wildcamping-python.json"

        # Instantiates a client
        storage_client = storage.Client()
        bucket = storage_client.get_bucket("wildcamping-326008.appspot.com")

        db = firestore.Client()

        for d in df.index:
            source_file_name = df["coverImage"][d]
            destination_blob_name = "images/%s.jpg" % df["id"][d]
            print(df["name"][d], destination_blob_name)
            data = df.loc[d].to_dict()
            data["coverImage"] = destination_blob_name

            doc_ref = db.collection("formdata").document(df["id"][d])
            print(data)
            doc_ref.set(data)

            blob = bucket.blob(destination_blob_name)
            blob.upload_from_filename(source_file_name)

    if 0:
        # Instantiates a client
        storage_client = storage.Client()

        # The name for the new bucket
        bucket_name = "wildcamping-326008.appspot.com"

        # Creates the new bucket
        # bucket = storage_client.create_bucket(bucket_name)

        bucket = storage_client.get_bucket(bucket_name)

        if 0:
            policy = bucket.get_iam_policy(requested_policy_version=3)
            policy.bindings.append({"role": "roles/storage.objectViewer", "members": {"allUsers"}})

            bucket.set_iam_policy(policy)

            print("Bucket {} is now publicly readable".format(bucket.name))

        if 1:
            source_file_name = "assets/white.jpg"
            destination_blob_name = "images/white"
            blob = bucket.blob(destination_blob_name)
            blob.upload_from_filename(source_file_name)

        if 0:
            source_file_name = "tamere.txt"
            destination_blob_name = "tamere.txt"
            blob = bucket.blob(destination_blob_name)
            blob.upload_from_filename(source_file_name)
            # blob.download_to_filename("tamere.txt")

            all_blobs = list(storage_client.list_blobs(bucket))
            print(all_blobs)
            print("Bucket {} created.".format(bucket.name))
            print("File {} uploaded to {}.".format(source_file_name, destination_blob_name))
