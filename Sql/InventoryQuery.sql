SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH
LE  AS
   ( SELECT LE1.[Item No_] AS ItemNo,
            MAX(NULLIF(LE1.[Location Code], '')) AS LocationCode,
            SUM(LE1.Quantity) AS Quantity,
            MAX(LE1.[Posting Date]) AS PostingDate
     FROM dbo.[Navision Company$Item Ledger Entry] AS LE1
     GROUP BY LE1.[Item No_] ),
I   AS
   ( SELECT I.No_ AS ItemNo,
            I.[Reorder Quantity] AS ReorderQuantity,
            I.[Safety Stock Quantity] AS SafetyStockQuantity
     FROM dbo.[Navision Company$Item] AS I ),
PNS AS
   ( SELECT SL.[Item No_] AS ItemNo,
            SUM(SL.[Qty_ Picked (Base)] - SL.[Qty_ Shipped (Base)]) AS PickedNotShippedQuantity
     FROM dbo.[Navision Company$Warehouse Shipment Line] AS SL
     GROUP BY SL.[Item No_] ),
RMQ AS
   ( SELECT AH.[Item No_] AS ItemNo,
            SUM(AH.[Remaining Quantity (Base)]) AS RemainingQuantity
     FROM dbo.[Navision Company$Assembly Header] AS AH
     GROUP BY AH.[Item No_] ),
OQ  AS
   ( SELECT PL.No_ AS ItemNo,
            SUM(PL.[Outstanding Qty_ (Base)]) AS OutstandingQuantity,
            MAX(PL.[Expected Receipt Date]) AS ExpectedReceiptDate
     FROM dbo.[Navision Company$Purchase Line] AS PL
     WHERE PL.[Outstanding Qty_ (Base)] <> 0
           AND PL.[Document Type] IN ( 1, 4 )
           AND PL.Type = 2
     GROUP BY PL.No_ ),
ITQ AS
   ( SELECT TL.[Item No_] AS ItemNo,
            SUM(TL.[Qty_ in Transit (Base)]) AS InTransitQuantity
     FROM dbo.[Navision Company$Transfer Line] AS TL
     GROUP BY TL.[Item No_] ),
RVQ AS
   ( SELECT RE.[Item No_] AS ItemNo,
            SUM(RE.[Quantity (Base)]) AS ReseveredQuantity
     FROM dbo.[Navision Company$Reservation Entry] AS RE
     WHERE RE.[Source Type] = 37
           AND RE.[Reservation Status] = 0
     GROUP BY RE.[Item No_] )
SELECT CASE WHEN LE.LocationCode IS NULL THEN LE.ItemNo ELSE LE.ItemNo + '-' + LE.LocationCode END AS INVENTORY_ID,
       LE.LocationCode AS INVENTORY_LOCATION_ID,
       LE.LocationCode AS LOCATION_ID,
       LE.ItemNo AS ITEM_ID,
       CAST(ISNULL(LE.Quantity, 0) - ISNULL(PNS.PickedNotShippedQuantity, 0) AS DECIMAL(38, 4)) AS QUANTITY_ON_HAND,
       CAST(ISNULL(RVQ.ReseveredQuantity, 0) AS DECIMAL(38, 4)) AS QUANTITY_RESERVED,
       CAST(ISNULL(OQ.OutstandingQuantity, 0) - ISNULL(RMQ.RemainingQuantity, 0) AS DECIMAL(38, 4)) AS QUANTITY_ON_ORDER,
       CAST(0 AS DECIMAL(38, 4)) AS QUANTITY_RECEIVED,
       CAST(ISNULL(ITQ.InTransitQuantity, 0) AS DECIMAL(38, 4)) AS QUANTITY_IN_TRANSIT,
       CAST(ISNULL(LE.Quantity, 0) - ISNULL(PNS.PickedNotShippedQuantity, 0) - ISNULL(RVQ.ReseveredQuantity, 0) AS DECIMAL(38, 4)) AS QUANTITY_AVAILABLE,
       CAST(ISNULL(I.ReorderQuantity, 0) AS DECIMAL(38, 4)) AS QUANTITY_REORDER,
       CAST(ISNULL(I.SafetyStockQuantity, 0) AS DECIMAL(38, 4)) AS QUANTITY_SAFETY,
       OQ.ExpectedReceiptDate AS DATE_ON_ORDER_DUE,
       CONVERT(CHAR(19), LE.PostingDate, 121) AS DATE_LAST_MODIFIED
FROM LE
     INNER JOIN I ON LE.ItemNo = I.ItemNo
     LEFT OUTER JOIN PNS ON LE.ItemNo = PNS.ItemNo
     LEFT OUTER JOIN RMQ ON LE.ItemNo = RMQ.ItemNo
     LEFT OUTER JOIN OQ ON LE.ItemNo = OQ.ItemNo
     LEFT OUTER JOIN ITQ ON LE.ItemNo = ITQ.ItemNo
     LEFT OUTER JOIN RVQ ON LE.ItemNo = RVQ.ItemNo;
