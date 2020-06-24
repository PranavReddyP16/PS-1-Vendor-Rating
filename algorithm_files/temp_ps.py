# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

#from flask import Flask,request
import pandas as pd
import numpy as np

app=Flask(__name__)
#pickle_in=open('regressor.pkl','rb')
#regressor=pickle.load(pickle_in)

@app.route('/')
def welcome():
    return "Welcome to Vendor Rating App"
if __name__=='__main__':
    app.run()

@app.route('/predict')
def predict_rating():
    norm_del_time=request.args.get('Normalised Delivery Time')
    percent_rec=request.args.get('Percentage Received')
    percent_kept=request.args.get('Percentage Kept')
    prediction=regressor.predict([[norm_del_time,percent_rec,percent_kept]])
    return "The rating of the vendor is " + str(prediction)
