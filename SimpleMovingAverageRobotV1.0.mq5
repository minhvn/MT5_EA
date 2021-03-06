﻿```jsx
 //+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property version "1.0"

#include<Trade\Trade.mqh>
CTrade trade;

input double mbuy=0.01;
input double msell=0.01;
input int ShortMAperiod=5;
input int MiddleMAperiod=10;
input int LongMAperiod=30;


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {



//+------------------------------------------------------------------+
//| MA                                                               |
//+------------------------------------------------------------------+
//the array for several prices
   double myShortMAarray[],myMiddleMAarray[],myLongMAarray[];
   
//last 20 candle for calculaion
//prpoerties of the MA
   int myShortMAdef=iMA(_Symbol,_Period,ShortMAperiod,0,MODE_SMA,PRICE_CLOSE);
   int myMiddleMAdef=iMA(_Symbol,_Period,MiddleMAperiod,0,MODE_SMA,PRICE_CLOSE);
   int myLongMAdef=iMA(_Symbol,_Period,LongMAperiod,0,MODE_SMA,PRICE_CLOSE);

//sort the price array from the current candle downwards
   ArraySetAsSeries(myShortMAarray,true);
   ArraySetAsSeries(myMiddleMAarray,true);
   ArraySetAsSeries(myLongMAarray,true);

//          EA          1Line now,candle,3 candle ,store result
   CopyBuffer(myShortMAdef,0,0,3,myShortMAarray);
   CopyBuffer(myMiddleMAdef,0,0,3,myMiddleMAarray);
   CopyBuffer(myLongMAdef,0,0,3,myLongMAarray);

   bool MAbuySignal=false;
   bool MAsellSignal=false;

   bool LevelOneBuyMA=false;
   bool LevelTwoBuyMA=false;
   bool LevelThreeBuyMA=false;

   bool LevelOneSellMA=false;
   bool LevelTwoSellMA=false;
   bool LevelThreeSellMA=false;



//level 1,2,3 Buy MA
   if(((myShortMAarray[0]>myMiddleMAarray[0])//short line corss UP middle line
     || (myMiddleMAarray[0]>myLongMAarray[0]))//middle line corss UP long line
      && ((myShortMAarray[1]<myLongMAarray[1])
      ||(myShortMAarray[1]<myMiddleMAarray[1]))
      )//Low to High
     {
     LevelOneBuyMA=true;//Level 1
      Comment("Low cross High");
     }

/*
//Rocket up!
   if((myShortMAarray[0]>myShortMAarray[1]>myShortMAarray[2])
      &&(myMiddleMAarray[0]>myMiddleMAarray[1]>myMiddleMAarray[2])
      &&(myLongMAarray[0]>myLongMAarray[1]>myLongMAarray[2]))
     {
      LevelTwoBuyMA=true;//Level 2
      Comment("Rocket up!");
     }
*/
		LevelTwoBuyMA=true;
/*
//V shape going up
   if((myShortMAarray[0]>myShortMAarray[1]>myShortMAarray[2])
      &&(myShortMAarray[1]>myShortMAarray[0]>myShortMAarray[2])
      &&((myShortMAarray[2]<myShortMAarray[0])&&(myShortMAarray[2]>myShortMAarray[1])
        ))
     {
      LevelThreeBuyMA=true;//level 3
      Comment("V shape UP");
     }
*/
	LevelThreeBuyMA=true;
//////////////////////////////////////////////////////////////////////////////////////////


//level 1,2,3 Sell MA
   if(((myShortMAarray[0]<myMiddleMAarray[0])//short line corss DOWN middle line
      || (myMiddleMAarray[0]<myLongMAarray[0]))//middle line corss DOWN long line
      && ((myShortMAarray[1]>myLongMAarray[1])
      ||(myShortMAarray[1]>myMiddleMAarray[1]))
      )//High to Low
     {
      LevelOneSellMA=true;//Level 1
     }

/*
   if((myShortMAarray[0]<myShortMAarray[1]<myShortMAarray[2])
      &&(myMiddleMAarray[0]<myMiddleMAarray[1]<myMiddleMAarray[2])
      &&(myLongMAarray[0]<myLongMAarray[1]<myLongMAarray[2]))
     {
      LevelTwoSellMA=true;//Level 2
      Comment("Rocket Down!");//Rocket Down!
     }
*/
		 LevelTwoSellMA=true;
//A shape going down
/*
   if((myShortMAarray[0]<myShortMAarray[1]<myShortMAarray[2])
      &&(myShortMAarray[1]<myShortMAarray[0]<myShortMAarray[2])
      &&((myShortMAarray[2]>myShortMAarray[0])&&(myShortMAarray[2]<myShortMAarray[1])
        ))
     {
      LevelThreeSellMA=true;//level 3
      Comment("A shape Down");
     }
 */    
	LevelThreeSellMA=true;

//match all the MA condition


   if((LevelOneBuyMA==true&& LevelTwoBuyMA==true) || //1,2
   	(LevelTwoBuyMA==true&&LevelThreeBuyMA==true) || //2,3
   	(LevelOneBuyMA==true&&LevelThreeBuyMA==true))		//1,3
     {
      MAbuySignal=true;
     }
   else
      MAbuySignal=false;

   if((LevelOneSellMA==true && LevelTwoSellMA==true) || //1,2
   	(LevelTwoSellMA==true&&LevelThreeSellMA==true) || //2,3
   	(LevelOneSellMA==true&&LevelThreeSellMA==true))		//1,3
     {
      MAsellSignal=true;
     }
   else
      MAsellSignal=false;
      
//+------------------------------------------------------------------+
//| END OF MA                                                        |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| MACD                                                             |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| END OF MACD                                                      |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| RSI                                                              |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|END OF RSI                                                        |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Account Management                                                |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Take Lost and Take Profit                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|differ of yesterday  Close and today Open                         |
//+------------------------------------------------------------------+

   double prev_dayClose=iClose(_Symbol,PERIOD_D1,1);
   double today_dayOpen=iOpen(_Symbol,PERIOD_D1,0);
   double differ=(today_dayOpen-prev_dayClose)/today_dayOpen*100;
   Comment("Differ of last day and today is: ",differ,"%");



//+------------------------------------------------------------------+
//|Buy and Sell Management                                           |
//+------------------------------------------------------------------+
   double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   double Balance=AccountInfoDouble(ACCOUNT_BALANCE);
   double Equity=AccountInfoDouble(ACCOUNT_EQUITY);


   if(MAbuySignal==true)
     {
      Comment("BUY!");
      if(Equity>= Balance)
         trade.Buy(mbuy,NULL,Ask,0,(Ask+100*_Point),NULL);
     }

   if(MAsellSignal==true)
     {
      Comment("SELL!");
      if(Equity>= Balance)
         trade.Sell(msell,NULL,Bid,0,(Bid+100*_Point),NULL);
     }


//+------------------------------------------------------------------+
//|Output Area test                                                  |
//+------------------------------------------------------------------+

//   string text="myshortMAarray0: "+DoubleToString(myshortMAarray[0]);
// "myshortMAarray1: " +DoubleToString(myshortMAarray[1]) +"\n"+
//  "myshortMAarray2: " +DoubleToString(myshortMAarray[2])+"\n"+
//  "myLongMAarray0: " +DoubleToString(myLongMAarray[0])+"\n"+
//  "myLongMAarray1: " +DoubleToString(myLongMAarray[1])+"\n"+
//  "myLongMAarray2: " +DoubleToString(myLongMAarray[2]);

//   Comment(text);
  }
//+------------------------------------------------------------------+
