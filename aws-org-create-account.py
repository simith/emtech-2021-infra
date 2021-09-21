import csv
import boto3

file = open('accounts.csv')
csvreader = csv.reader(file)

header = next(csvreader)

org_client=boto3.client('organizations')

for row in csvreader:
    
    print("\n\n===============[CREATE ACCOUNT]=====================")
    print(f"Creating account: ")
    print(f"Account name: [{row[1]}]")
    print(f"Account email: [{row[0]}]")
    val = input("Continue: y/n ")
    if val[0] == 'y':
        try:
            org_client.create_account(Email=row[0],
                                  AccountName=row[1])
            print(f"Creating account: {row[0]} {row[1]}")
            print("====================================")
        except Exception as e:
            print(e)
            exit()
    elif val[0] == 'n':
        print("====================================")
        print(f"\n\nSkipping Account creation for {row[1]}\n\n")
        print("====================================")
    else:
        print("====================================")
        print(f"\n\nExiting now\n\n")
        exit()
        print("====================================")

    



