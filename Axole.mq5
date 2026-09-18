//+------------------------------------------------------------------+
//| Axole-.mq5 |
//| Created for mxillo |
//| MT5 EA |
//+------------------------------------------------------------------+
#property copyright "mxillo Axole-"
#property version "1.00"

input double LotSize = 0.01;
input int FastMA = 10;
input int SlowMA = 20;
input int Magic = 123456;

int fast_handle, slow_handle;

int OnInit(){
   fast_handle = iMA(_Symbol, PERIOD_M1, FastMA, 0, MODE_SMA, PRICE_CLOSE);
   slow_handle = iMA(_Symbol, PERIOD_M1, SlowMA, 0, MODE_SMA, PRICE_CLOSE);
   return(INIT_SUCCEEDED);
}

void OnTick(){
   double fast[], slow[];
   CopyBuffer(fast_handle,0,0,2,fast);
   CopyBuffer(slow_handle,0,0,2,slow);
   ArraySetAsSeries(fast,true);
   ArraySetAsSeries(slow,true);

   bool is_buy = fast[1] < slow[1] && fast[0] > slow[0];
   bool is_sell = fast[1] > slow[1] && fast[0] < slow[0];

   if(PositionSelect(_Symbol)) return; // already in trade

   if(is_buy) OpenTrade(ORDER_TYPE_BUY);
   if(is_sell) OpenTrade(ORDER_TYPE_SELL);
}

void OpenTrade(ENUM_ORDER_TYPE type){
   MqlTradeRequest req; MqlTradeResult res; ZeroMemory(req);
   req.action = TRADE_ACTION_DEAL;
   req.symbol = _Symbol;
   req.volume = LotSize;
   req.type = type;
   req.price = (type==ORDER_TYPE_BUY)? SymbolInfoDouble(_Symbol,SYMBOL_ASK) : SymbolInfoDouble(_Symbol,SYMBOL_BID);
   req.magic = Magic;
   req.deviation = 20;
   OrderSend(req,res);
}