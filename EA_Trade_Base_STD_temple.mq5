//+------------------------------------------------------------------+
//|                                            Channel_Trade_EA1.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\PositionInfo.mqh> //包含部位的資訊庫
#include <Trade\Trade.mqh>    //包含執行的交易庫
#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>

CTrade         m_trade;
CPositionInfo  m_position; //獲取持倉信息的結構體
CSymbolInfo    m_symbol;   // symbol info object
CAccountInfo   m_account;                    // account info wrapper

CDealInfo      m_deal;                       // deals object
COrderInfo     m_order;

input long     m_magic           = 114514;      // magic number
input ushort   InpStopLoss       = 100;      // StopLoss 50.0 points)
input ushort   InpTakeProfit     = 50;      // TakeProfit 50.0 points)

double m_adjusted_point;
double ExtStopLoss      = 0.0;
double ExtTakeProfit    = 0.0;

int iMA_fast_handle;     //Fast MA 晝圖用
int iMA_slow_handle;    //slow MA 存儲句柄變量
double iMA_fast_buf[];   //
double iMA_slow_buf[];   //Fast and slow MABuffer

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
 if(!m_symbol.Name(Symbol())) // sets symbol name
          return(INIT_FAILED);
          
          //---
     m_trade.SetExpertMagicNumber(m_magic);
          
          //--- tuning for 3 or 5 digits
     int digits_adjust = 1;

     if(m_symbol.Digits() == 3 || m_symbol.Digits() == 5)
          digits_adjust = 10;

     if(m_symbol.Digits() == 2) // 如果商品是1.00 , us30, ustec, xauusd.
          digits_adjust = 100; // SL 200 點 *100 = 20,000/100;

     m_adjusted_point = m_symbol.Point() * digits_adjust;

     ExtStopLoss       = InpStopLoss       * m_adjusted_point;
     ExtTakeProfit     = InpTakeProfit     * m_adjusted_point;
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
