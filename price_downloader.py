
"""
This program is written by Navin Kumar to download the prices of given security from www.yahoofinance.com.
"""
import csv
import pandas as pd
import pandas_datareader as pdr
import datetime as dt


def price():
    a = input("Enter the security - ")
    download_source = r'C:\Users\Public\%s.csv' % a
    b = input(str("Start date in format yyyy/mm/dd - "))
    # start = dt.datetime(2020, 4, 27) - Start date can also be saved as a variable "start"
    c = input(str("End date in format yyyy/mm/dd - "))
    # end = dt.datetime(2020, 4, 28) - Start date can also be saved as a variable "end"
    df = pdr.get_data_yahoo(a, b, c)
    # df = pdr.get_data_yahoo(aapl, start, end)
    print(df['Close'].head(45))
    # df.head(45).to_csv(download_source)
    df['Close'].head(45).to_csv(download_source)


while True:
    print("***************************************************************************************")
    print("You are going to download the price of a security/securities from Yahoo Finance")
    print("Press Enter to continue or press X to exit")
    roll = input()
    price()
    print("The output file has been generated in C:/Users/Public folder")
