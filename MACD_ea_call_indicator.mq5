//+------------------------------------------------------------------+
//|                                              Moving Averages.mq5 |
//|                   Copyright 2009-2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009-2017, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property description "Moving Average Convergence/Divergence"
#include <MovingAverages.mqh>
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_type2   DRAW_LINE
#property indicator_color1  Silver
#property indicator_color2  Red
#property indicator_width1  2
#property indicator_width2  1
#property indicator_label1  "MACD"
#property indicator_label2  "Signal"
#define rates_total Bars(_Symbol, ENUM_TIMEFRAMES(_Period) )
#property tester_indicator "MACD_SIGNALTRY_V1.ex5"
int MACD_handle=INVALID_HANDLE;
double         Label1Buffer[];
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(void)
  {
 // IndicatorRelease(MACD_handle);
  
  int copy=CopyBuffer(MACD_handle,0,0,rates_total,Label1Buffer);
  GetLastError();
  }

int OnInit() 
  { 
//--- 指标缓冲区绘图 
   SetIndexBuffer(0,Label1Buffer,INDICATOR_DATA); 
   ResetLastError(); 
  MACD_handle=iCustom(_Symbol,PERIOD_CURRENT,"MACD_SIGNALTRY_V1"); 
   //Print("MA_handle = ",MA_handle,"  error = ",GetLastError()); 
//--- 
   return(INIT_SUCCEEDED); 
  } 
  
  