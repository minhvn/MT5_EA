//+------------------------------------------------------------------+
//|                                              Moving Averages.mq5 |
//|                   Copyright 2009-2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2009-2017, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>

input double MaximumRisk        = 0.02;    // Maximum Risk in percentage
input double DecreaseFactor     = 3;       // Descrease factor
input int    MovingPeriod       = 12;      // Moving Average period
input int    MovingShift        = 6;       // Moving Average shift
//---
int    ExtHandle=0;
bool   ExtHedging=false;
CTrade ExtTrade;

#define MA_MAGIC 1234501

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(void)
  {
//---
   if(SelectPosition())//check交易種類和magic num，選好倉位
      CheckForClose();//先平倉
   else
      CheckForOpen();//後開倉
//---
  }

//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double TradeSizeOptimized(void)//交易量
  {
   double price=0.0;
   double margin=0.0;
//--- select lot size
   if(!SymbolInfoDouble(_Symbol,SYMBOL_ASK,price))//如果賣價與價錢一致
      return(0.0);
   if(!OrderCalcMargin(ORDER_TYPE_BUY,_Symbol,1.0,price,margin))//訂單所需保證金
      return(0.0);//訂單類型，商品名，交易量，開盤價，保證金
   if(margin<=0.0)//如果沒有保證金
      return(0.0);

   double lot=NormalizeDouble(AccountInfoDouble(ACCOUNT_MARGIN_FREE)*MaximumRisk/margin,2);
   																//手數=賬戶最大保證金X最大風險/目前保證金
   
//--- calculate number of losses orders without a break
   if(DecreaseFactor>0)
     {
      //--- select history for access
      HistorySelect(0,TimeCurrent());//由開始到現在檢索歷史
      //---
      int    orders=HistoryDealsTotal();  // total history deals
      int    losses=0;                    // number of losses orders without a break 連輸

      for(int i=orders-1; i>=0; i--)//訂單數到0
        {
         ulong ticket=HistoryDealGetTicket(i);//交易數量
         if(ticket==0)
           {
            Print("HistoryDealGetTicket failed, no trade history");
            break;
           }
         //--- check symbol
         if(HistoryDealGetString(ticket,DEAL_SYMBOL)!=_Symbol)
            continue;
         //--- check Expert Magic number
         if(HistoryDealGetInteger(ticket,DEAL_MAGIC)!=MA_MAGIC)
            continue;
         //--- check profit
         double profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);//利潤
         if(profit>0.0)
            break;
         if(profit<0.0)//無獲益，連輸增加
            losses++;
        }
      //---
      if(losses>1)//連輸多於一次
         lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
         							//手數-（手數*連輸）/減少因子
     }
//--- normalize and check limits
   double stepvol=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);//交易执行的最小成交量更改步骤
   lot=stepvol*NormalizeDouble(lot/stepvol,0);
				//步骤*手數/步骤
				
   double minvol=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);//訂單中最小交易量
   if(lot<minvol)
      lot=minvol;

   double maxvol=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);//訂單中最大交易量
   if(lot>maxvol)
      lot=maxvol;
//--- return trading volume
   return(lot);
  }
//+------------------------------------------------------------------+
//| Check for open position conditions                               |
//+------------------------------------------------------------------+
void CheckForOpen(void)//什麽時候開倉
  {
   MqlRates rt[2];//OHLC等訊息，copy過去3支bar
//--- go trading only for first ticks of new bar
   if(CopyRates(_Symbol,_Period,0,2,rt)!=2)//0開始copy到2，現在到過去
     {
      Print("CopyRates of ",_Symbol," failed, no history");
      return;
     }
   if(rt[1].tick_volume>1)//如果上一支bar有交易，就不再交易
      return;
//--- get current Moving Average
   double   ma[1];
   if(CopyBuffer(ExtHandle,0,0,1,ma)!=1)//複製兩個ima數據到ma[]里
     {
      Print("CopyBuffer from iMA failed, no data");
      return;
     }
//--- check signals
   ENUM_ORDER_TYPE signal=WRONG_VALUE;//先定義false信號

   if(rt[0].open>ma[0] && rt[0].close<ma[0])//開盤價>MA，收盤價<MA
      signal=ORDER_TYPE_SELL;    // sell conditions 賣出！
   else
     {
      if(rt[0].open<ma[0] && rt[0].close>ma[0])//開盤價<MA，收盤價>MA
         signal=ORDER_TYPE_BUY;  // buy conditions	買入！
     }
//--- additional checking
   if(signal!=WRONG_VALUE)//如果信號正確
     {
      if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) && Bars(_Symbol,_Period)>100)//如果終端可以交易，走了100支bar
      
         ExtTrade.PositionOpen(_Symbol,signal,TradeSizeOptimized(),	//按設置參數開倉
                               SymbolInfoDouble(_Symbol,signal==ORDER_TYPE_SELL ? SYMBOL_BID:SYMBOL_ASK),
                               0,0);//商品名，訂單類型，交易量，執行價格，止損價，止賺價，注釋
     }
//---
  }
//+------------------------------------------------------------------+
//| Check for close position conditions                              |
//+------------------------------------------------------------------+
void CheckForClose(void) //什麽時候平倉
  {
   MqlRates rt[2];//OHLC等訊息，copy過去3支bar
   //Print("rt: ", );
//--- go trading only for first ticks of new bar
   if(CopyRates(_Symbol,_Period,0,2,rt)!=2)//0開始copy到2，現在到過去
     {
      Print("CopyRates of ",_Symbol," failed, no history");
      return;
     }
   if(rt[1].tick_volume>1)//如果上一支bar有交易，就不再交易
      return;
      
//--- get current Moving Average
   double   ma[1];//
   if(CopyBuffer(ExtHandle,0,0,1,ma)!=1)//複製兩個ima數據到ma[]里
     {
      Print("CopyBuffer from iMA failed, no data");
      return;
     }
     
//--- positions already selected before
   bool signal=false;
   long type=PositionGetInteger(POSITION_TYPE);//1 or 0 		1就是有倉
   //Print("type: ",type);

   if(type==(long)POSITION_TYPE_BUY && rt[0].open>ma[0] && rt[0].close<ma[0])//已經買了，開盤價>MA,收盤價<MA
      signal=true;
      
   if(type==(long)POSITION_TYPE_SELL && rt[0].open<ma[0] && rt[0].close>ma[0])//已經賣了，開盤價<MA,收盤價>MA
      signal=true;
      
//--- additional checking
   if(signal)//==true
     {
      if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) && Bars(_Symbol,_Period)>100)//如果終端允許交易，超过100支bar
         ExtTrade.PositionClose(_Symbol,3);//平倉，3個滑點
     }
//---
  }
//+------------------------------------------------------------------+
//| Position select depending on netting or hedging                  |
//+------------------------------------------------------------------+
bool SelectPosition()
  {
   bool res=false;
//--- check position in Hedging mode
   if(ExtHedging)//對衝
     {
      uint total=PositionsTotal();//倉位
      for(uint i=0; i<total; i++)//數倉位
        {
         string position_symbol=PositionGetSymbol(i);//返回的交易品种与开仓位置的值保持一致 返回HK50
         //Print("position_symbol: ",position_symbol);
         if(_Symbol==position_symbol && MA_MAGIC==PositionGetInteger(POSITION_MAGIC))//對齊交易種類和magic num
           {
            res=true;
            break;
           }
        }
     }

//--- check position in Netting mode
   else
     {
      if(!PositionSelect(_Symbol))//为接下来的工作选择一个仓位
         return(false);
      else
         return(PositionGetInteger(POSITION_MAGIC)==MA_MAGIC); //---check Magic number
     }
//--- result for Hedging mode
   return(res);
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//--- prepare trade class to control positions if hedging mode is active
   ExtHedging=((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
   ExtTrade.SetExpertMagicNumber(MA_MAGIC);
   ExtTrade.SetMarginMode();
   ExtTrade.SetTypeFillingBySymbol(Symbol());
//--- Moving Average indicator
   ExtHandle=iMA(_Symbol,_Period,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE);
   if(ExtHandle==INVALID_HANDLE)
     {
      printf("Error creating MA indicator");
      return(INIT_FAILED);
     }
//--- ok
   return(INIT_SUCCEEDED);
  }

  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
