//+------------------------------------------------------------------+
//|                                                         MACD.mq5 |
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
//--- input parameters
input int                InpFastEMA=12;               // Fast EMA period
input int                InpSlowEMA=26;               // Slow EMA period
input int                InpSignalSMA=9;              // Signal SMA period
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_CLOSE; // Applied price
//--- indicator buffers
double                   ExtMacdBuffer[];
double                   ExtSignalBuffer[];
double                   ExtFastMaBuffer[];
double                   ExtSlowMaBuffer[];
//--- MA handles
int                      ExtFastMaHandle;
int                      ExtSlowMaHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtMacdBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtSignalBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtFastMaBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtSlowMaBuffer,INDICATOR_CALCULATIONS);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,InpSignalSMA-1);
//--- name for Dindicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"MACD("+string(InpFastEMA)+","+string(InpSlowEMA)+","+string(InpSignalSMA)+")");
//--- get MA handles
   ExtFastMaHandle=iMA(NULL,0,InpFastEMA,0,MODE_EMA,InpAppliedPrice);
   ExtSlowMaHandle=iMA(NULL,0,InpSlowEMA,0,MODE_EMA,InpAppliedPrice);
//--- initialization done
  }
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- check for data
//Print("rates_total： ",rates_total);//多少支bar
//Print("prev_calculated: ",prev_calculated);

   if(rates_total<InpSignalSMA)
      GetLastError();
//--- not all data may be calculated
   int calculated=BarsCalculated(ExtFastMaHandle);
// Print("calculated",calculated);

   if(calculated<rates_total)
     {
      Print("Not all data of ExtFastMaHandle is calculated (",calculated,"bars ). Error",GetLastError());
      GetLastError();
     }
   calculated=BarsCalculated(ExtSlowMaHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtSlowMaHandle is calculated (",calculated,"bars ). Error",GetLastError());
      GetLastError();
     }

//--- we can copy not all data
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0)
      to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0)
         to_copy++;
     }

//--- get Fast EMA buffer
   if(IsStopped())
      GetLastError(); //Checking for stop flag
   if(CopyBuffer(ExtFastMaHandle,0,0,to_copy,ExtFastMaBuffer)<=0)
     {
      Print("Getting fast EMA is failed! Error",GetLastError());
      GetLastError();
     }
//--- get SlowSMA buffer
   if(IsStopped())
      GetLastError(); //Checking for stop flag
   if(CopyBuffer(ExtSlowMaHandle,0,0,to_copy,ExtSlowMaBuffer)<=0)
     {
      Print("Getting slow SMA is failed! Error",GetLastError());
      GetLastError();
     }

//---
   int limit;
   if(prev_calculated==0)
      limit=0;
   else
      limit=prev_calculated-1;
//--- calculate MACD
   double MACD_array[];
//int MACD_arrayHandle=MACD_array[8];

			int sellCount=0;
        int buyCount=0;
        int MACD_array_MAX;
        int MACD_array_MIN;
        
   for(int i=limit; i<rates_total && !IsStopped(); i++)//0至现在的bar
     {
      ExtMacdBuffer[i]=ExtFastMaBuffer[i]-ExtSlowMaBuffer[i];
      ExtMacdBuffer[i]=int(ExtMacdBuffer[i]);
      ArrayCopy(MACD_array,ExtMacdBuffer,0,i-4);

      // Print("MACD_array[0]",MACD_array[0]);//now macd value
      //Print("MACD_array[8]",MACD_array[8]);




      //MACD_array[8]=CopyBuffer(MACD_array,Handle,8,i-8,8);

      //Print("ExtMacdBuffer[",i,"]",ExtMacdBuffer[i]);//MACD value

      //Print("ExtMacdBuffer[i-1]",ExtMacdBuffer[temp]);
      /*
      //bool Con_down_left=ExtMacdBuffer[i-7]>ExtMacdBuffer[i-6]>ExtMacdBuffer[i-5]>ExtMacdBuffer[i-4];
      //bool Con_down_right=ExtMacdBuffer[i-4]<ExtMacdBuffer[i-3]<ExtMacdBuffer[i-2]<ExtMacdBuffer[i-1];
       bool Con_down_left=ExtMacdBuffer[i-5]>ExtMacdBuffer[i-4];
       bool Con_down_right=ExtMacdBuffer[i-4]<ExtMacdBuffer[i-3];

*/
    



           
     }

		 MACD_array_MAX=ArrayMaximum(MACD_array,0,WHOLE_ARRAY);
      MACD_array_MIN=ArrayMinimum(MACD_array,0,WHOLE_ARRAY);
        
      //Print("MACD_array_MAX: ",MACD_array_MAX);//2
      //Print("MACD_array_MIN: ",MACD_array_MIN);//1


           if(MACD_array[MACD_array_MAX]>0&&MACD_array[MACD_array_MIN]>0)
             {
              if(MACD_array[MACD_array_MAX]==MACD_array[2])
                {
                // Print("Sell!!!!!!");
                 sellCount++;
                 Comment("sellCount: ",sellCount);
                }
              else
                Print("");
                	
             }


           if(MACD_array[MACD_array_MAX]<0&&MACD_array[MACD_array_MIN]<0)
             {
              if(MACD_array[MACD_array_MIN]==MACD_array[2])
                {
                 Print("Buy!!!!!!");
                 buyCount++;
                 Comment("buyCount: ",buyCount);
                }
              else
                Print("");
             }



//Print("MACD_array[0]: ",MACD_array[0]);//oldest MACD
// Print("MACD_array[1]: ",MACD_array[1]);
//Print("MACD_array[2]: ",MACD_array[2]);
// Print("MACD_array[3]: ",MACD_array[3]);//center MACD
//Print("MACD_array[4]: ",MACD_array[4]);
//Print("MACD_array[5]: ",MACD_array[5]);
// Print("MACD_array[6]: ",MACD_array[6]);//now MACD

   /*

         bool Con_down_left=(MACD_array[0]>=MACD_array[1]>=MACD_array[2]>MACD_array[3]);//lowset is [3]
            bool Con_down_right=(MACD_array[3]<MACD_array[4]<=MACD_array[5]<=MACD_array[6]);//V shape
            //if(MACD_array[6]>0) should be signal
            if(Con_down_left&&Con_down_right)
               Print("Sell!!!!!!");
               else
                  Print("");

                  bool Con_up_left=(MACD_array[0]<=MACD_array[1]<=MACD_array[2]<MACD_array[3]);//highest is [3]
                  bool Con_up_right=(MACD_array[3]>MACD_array[4]>=MACD_array[5]>=MACD_array[6]);//A shape
                  //if(MACD_array[6]<0) shoule be signal
                  if(Con_up_left&&Con_up_right)

               Print("Buy!!!!!!");
               else
                  Print("");
    */




   /*
   bool Con_down_left=false;
   bool Con_down_right=false;
   bool Con_up_left=false;
   bool Con_up_right=false;

   if(MACD_array[0]>MACD_array[1]>MACD_array[2])
      Con_down_left=true;
      if(MACD_array[2]<MACD_array[3]<MACD_array[4])
         Con_down_right=true;
   */

///////////////////////////////////////////////////////////////////////////////////////////////////////
   /*
      double MACD_array_MAX=ArrayMaximum(MACD_array,0,WHOLE_ARRAY);
      double MACD_array_MIN=ArrayMinimum(MACD_array,0,WHOLE_ARRAY);

      if(MACD_array_MAX<0&&MACD_array_MIN<0)

     {
         bool Con_V_left=(MACD_array[0]>MACD_array[1]>MACD_array[2]);//lowset is [3]
         bool Con_V_right=(MACD_array[2]<MACD_array[3]<MACD_array[4]);//V shape
         //if(MACD_array[6]>0) should be signal
         if(Con_V_left&&Con_V_right)
            Print("Buy!!!!!!");
         else
            Print("");

        }




      if(MACD_array_MAX>0&&MACD_array_MIN>0)
     {
      bool Con_A_left=(MACD_array[0]<MACD_array[1]<MACD_array[2]);//highest is [3]
       bool Con_A_right=(MACD_array[2]>MACD_array[3]>MACD_array[4]);//A shape
         //if(MACD_array[6]<0) shoule be signal
         if(Con_A_left&&Con_A_right)

            Print("Sell!!!!!!");
         else
            Print("");
        }
   */
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
   /*
     Print("ExtMacdBuffer[0]: ",ExtMacdBuffer[0]);//死数
     Print("ExtMacdBuffer[1]: ",ExtMacdBuffer[1]);
     Print("ExtMacdBuffer[2]: ",ExtMacdBuffer[2]);
     Print("ExtMacdBuffer[3]: ",ExtMacdBuffer[3]);
     Print("ExtMacdBuffer[4]: ",ExtMacdBuffer[4]);
     Print("ExtMacdBuffer[5]: ",ExtMacdBuffer[5]);
   */
   /*
   Print("ExtSignalBuffer[0]",ExtSignalBuffer[0]);
   Print("ExtSignalBuffer[1]",ExtSignalBuffer[1]);
   Print("ExtSignalBuffer[2]",ExtSignalBuffer[2]);
   Print("ExtSignalBuffer[3]",ExtSignalBuffer[3]);


   */


//Comment("Buy!!!!!!!!");

   /*
   Print("ExtFastMaBuffer[0]",ExtFastMaBuffer[0]);//25822
   Print("ExtFastMaBuffer[1]",ExtFastMaBuffer[1]);
   Print("ExtFastMaBuffer[2]",ExtFastMaBuffer[2]);
   Print("ExtFastMaBuffer[3]",ExtFastMaBuffer[3]);


   Print("ExtSlowMaBuffer[0]",ExtSlowMaBuffer[0]);
   Print("ExtSlowMaBuffer[1]",ExtSlowMaBuffer[1]);
   Print("ExtSlowMaBuffer[2]",ExtSlowMaBuffer[2]);
   */

//--- calculate Signal
   SimpleMAOnBuffer(rates_total,prev_calculated,0,InpSignalSMA,ExtMacdBuffer,ExtSignalBuffer);

//Print("SimpleMAOnBuffer: ",SimpleMAOnBuffer(rates_total,prev_calculated,0,InpSignalSMA,ExtMacdBuffer,ExtSignalBuffer));
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
