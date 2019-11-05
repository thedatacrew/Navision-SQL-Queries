SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT SL.[Document No_] + N'-' + CAST(SL.[Line No_] AS NVARCHAR(32)) AS SALES_QUOTE_LINE_ID,
       SH.[Bill-to Customer No_] AS CUSTOMERID_INVOICE,
       SH.[Sell-to Customer No_] AS CUSTOMERID_QUOTE,
       SUBSTRING(SH.[Assigned User ID], CHARINDEX('\', SH.[Assigned User ID]) + 1, 50) AS CUSTOMER_SERVICE_REP_ID,
       ISNULL(NULLIF(SH.[Currency Code], N''), GLS.[LCY Code]) AS CURRENCY_ID,
       SL.No_ AS ITEM_ID,
       SH.[Salesperson Code] AS SALES_REP_ID,
       SL.[Location Code] AS LOCATION_ID,
       SL.[Document No_] AS SALES_QUOTE_NO,
       SL.[Line No_] AS LINE_NUMBER,
       NULL AS DELIVERY_NUMBER,
       CONVERT(CHAR(10), SH.[Order Date], 121) AS SALES_QUOTE_DATE,
       CASE WHEN SH.Status = 0 THEN 'Planned'
           WHEN SH.Status = 1 THEN 'Released'
           WHEN SH.Status = 2 THEN 'Released'
           WHEN SH.Status = 3 THEN 'Released'
           ELSE 'Unknown'
       END AS QUOTATION_STATUS,
       CASE WHEN SH.Status = 0 THEN 'Planned'
           WHEN SH.Status = 1 THEN 'Released'
           WHEN SH.Status = 2 THEN 'Released'
           WHEN SH.Status = 3 THEN 'Released'
           ELSE 'Unknown'
       END AS LINE_STATUS,
       SL.Description AS DESCRIPTION,
       CAST(SL.Quantity AS DECIMAL(38, 4)) AS QUANTITY_QUOTED,
       SL.[Unit of Measure] AS UNIT_OF_MEASURE,
       SH.[VAT Bus_ Posting Group] AS TAX_CODE,
       CAST(SL.[VAT _] AS DECIMAL(38, 4)) AS TAX_RATE,
       SL.[Requested Delivery Date] AS DATE_DELIVERY_REQUIRED,
       SL.[Planned Shipment Date] AS DATE_SHIPMENT_PLANNED,
       CAST(SL.[Line Discount _] AS DECIMAL(38, 4)) AS LINE_DISCOUNT_RATE,
       CAST(SH.[Invoice Discount Value] AS DECIMAL(38, 4)) AS HEADER_DISCOUNT_RATE,
       CAST(SL.[Line Discount _] AS DECIMAL(38, 4)) AS TOTAL_DISCOUNT_RATE,
       CAST(SL.[Unit Cost] AS DECIMAL(38, 4)) AS SALES_UNIT_COST,
       CAST(SL.[Unit Price] AS DECIMAL(38, 4)) AS SALES_UNIT_PRICE,
       CAST(SL.[Line Discount Amount] AS DECIMAL(38, 4)) AS SALES_DISCOUNT_AMOUNT,
       CAST(SL.Amount AS DECIMAL(38, 4)) AS SALES_NET_AMOUNT,
       CAST(SL.[Amount Including VAT] - SL.Amount AS DECIMAL(38, 4)) AS SALES_TAX_AMOUNT,
       CAST(SL.[Amount Including VAT] AS DECIMAL(38, 4)) AS SALES_GROSS_AMOUNT,
       CAST(SL.[Unit Cost (LCY)] AS DECIMAL(38, 4)) AS BASE_UNIT_COST,
       CAST(CASE WHEN SL.[Unit Price] = 0 THEN SL.Amount ELSE ( 1 / SL.[Unit Price] ) * SL.Amount END AS DECIMAL(38, 4)) AS BASE_UNIT_PRICE,
       CAST(CASE WHEN SH.[Currency Factor] = 0 THEN SL.[Line Discount Amount]
                ELSE ( 1 / SH.[Currency Factor] ) * SL.[Line Discount Amount]
            END AS DECIMAL(38, 4)) AS BASE_DISCOUNT_AMOUNT,
       CAST(CASE WHEN SH.[Currency Factor] = 0 THEN SL.Amount ELSE ( 1 / SH.[Currency Factor] ) * SL.Amount END AS DECIMAL(38, 4)) AS BASE_NET_AMOUNT,
       CAST(CASE WHEN SH.[Currency Factor] = 0 THEN SL.[Amount Including VAT] - SL.Amount
                ELSE ( 1 / SH.[Currency Factor] ) * ( SL.[Amount Including VAT] - SL.Amount )
            END AS DECIMAL(38, 4)) AS BASE_TAX_AMOUNT,
       CAST(CASE WHEN SH.[Currency Factor] = 0 THEN SL.[Amount Including VAT]
                ELSE ( 1 / SH.[Currency Factor] ) * SL.[Amount Including VAT]
            END AS DECIMAL(38, 4)) AS BASE_GROSS_AMOUNT,
       SP.Name AS SALES_REP_NAME,
       U.[Full Name] AS CUSTOMER_SERVICE_REP_NAME,
       NULL AS VESSEL_NAME,
       SH.[Ship-to City] AS DELIVERY_LOCATION,
       SH.[Shipment Method Code] + ' - ' + SM.Description AS DELIVERY_TERMS,
       SH.[External Document No_] AS CUSTOMER_REFERENCE,
       NULL AS CANCEL_REASON,
       NULL AS PROBABILITY,
       NULL AS LOST_TO,
       NULL AS WIN_LOSE_REASON,
       CONVERT(CHAR(19), SH.[Document Date], 121) AS DATE_LAST_MODIFIED
FROM dbo.[Navision Company$Sales Header] AS SH
     LEFT JOIN dbo.[Navision Company$Sales Line] AS SL ON SH.[Document Type] = SL.[Document Type]
                                                          AND SH.No_ = SL.[Document No_]
     LEFT JOIN dbo.[Navision Company$General Ledger Setup] AS GLS ON 1 = 1
     LEFT JOIN dbo.[Navision Company$Salesperson_Purchaser] AS SP ON SH.[Salesperson Code] = SP.Code
     LEFT JOIN dbo.[User] AS U ON SH.[Assigned User ID] = U.[User Name]
     LEFT JOIN dbo.[Navision Company$Shipment Method] AS SM ON SH.[Shipment Method Code] = SM.Code
                                                               AND SH.[Document Type] = 0
                                                               AND SL.Amount <> 0
UNION ALL
SELECT SL.[Document No_] + N'-' + CAST(SL.[Line No_] AS NVARCHAR(32)) AS SALES_QUOTE_LINE_ID,
       SH.[Bill-to Customer No_] AS CUSTOMERID_INVOICE,
       SH.[Bill-to Customer No_] AS CUSTOMERID_QUOTE,
       SUBSTRING(SH.[Assigned User ID], CHARINDEX('\', SH.[Assigned User ID]) + 1, 50) AS CUSTOMER_SERVICE_REP_ID,
       ISNULL(NULLIF(SH.[Currency Code], N''), GLS.[LCY Code]) AS CURRENCY_ID,
       SL.No_ AS ITEM_ID,
       SH.[Salesperson Code] AS SALES_REP_ID,
       NULL AS LOCATION_ID,
       SL.[Document No_] AS SALES_QUOTE_NO,
       SL.[Line No_] AS LINE_NUMBER,
       NULL AS DELIVERY_NUMBER,
       CONVERT(CHAR(10), SH.[Order Date], 121) AS SALES_QUOTE_DATE,
       CASE WHEN SH.Status = 0 THEN 'Planned'
           WHEN SH.Status = 1 THEN 'Released'
           WHEN SH.Status = 2 THEN 'Released'
           WHEN SH.Status = 3 THEN 'Released'
           ELSE 'Unknown'
       END AS QUOTATION_STATUS,
       CASE WHEN SH.Status = 0 THEN 'Planned'
           WHEN SH.Status = 1 THEN 'Released'
           WHEN SH.Status = 2 THEN 'Released'
           WHEN SH.Status = 3 THEN 'Released'
           ELSE 'Unknown'
       END AS LINE_STATUS,
       SL.Description AS DESCRIPTION,
       CAST(SL.Quantity AS DECIMAL(38, 4)) AS QUANTITY_QUOTED,
       SL.[Unit of Measure] AS UNIT_OF_MEASURE,
       SH.[VAT Bus_ Posting Group] AS TAX_CODE,
       CAST(SL.[VAT _] AS DECIMAL(38, 4)) AS TAX_RATE,
       SL.[Requested Delivery Date] AS DATE_DELIVERY_REQUIRED,
       SH.[Expected Finishing Date] AS DATE_SHIPMENT_PLANNED,
       CAST(SL.[Line Discount _] AS DECIMAL(38, 4)) AS LINE_DISCOUNT_RATE,
       CAST(SH.[Invoice Discount Value] AS DECIMAL(38, 4)) AS HEADER_DISCOUNT_RATE,
       CAST(SL.[Line Discount _] AS DECIMAL(38, 4)) AS TOTAL_DISCOUNT_RATE,
       CAST(SL.[Unit Cost] AS DECIMAL(38, 4)) AS SALES_UNIT_COST,
       CAST(SL.[Unit Price] AS DECIMAL(38, 4)) AS SALES_UNIT_PRICE,
       CAST(SL.[Line Discount Amount] AS DECIMAL(38, 4)) AS SALES_DISCOUNT_AMOUNT,
       CAST(SL.Amount AS DECIMAL(38, 4)) AS SALES_NET_AMOUNT,
       CAST(SL.[Amount Including VAT] - SL.Amount AS DECIMAL(38, 4)) AS SALES_TAX_AMOUNT,
       CAST(SL.[Amount Including VAT] AS DECIMAL(38, 4)) AS SALES_GROSS_AMOUNT,
       CAST(SL.[Unit Cost (LCY)] AS DECIMAL(38, 4)) AS BASE_UNIT_COST,
       CAST(CASE WHEN SL.[Unit Price] = 0 THEN SL.Amount ELSE ( 1 / SL.[Unit Price] ) * SL.Amount END AS DECIMAL(38, 4)) AS BASE_UNIT_PRICE,
       CAST(CASE WHEN SH.[Currency Factor] = 0 THEN SL.[Line Discount Amount]
                ELSE ( 1 / SH.[Currency Factor] ) * SL.[Line Discount Amount]
            END AS DECIMAL(38, 4)) AS BASE_DISCOUNT_AMOUNT,
       CAST(CASE WHEN SH.[Currency Factor] = 0 THEN SL.Amount ELSE ( 1 / SH.[Currency Factor] ) * SL.Amount END AS DECIMAL(38, 4)) AS BASE_NET_AMOUNT,
       CAST(CASE WHEN SH.[Currency Factor] = 0 THEN SL.[Amount Including VAT] - SL.Amount
                ELSE ( 1 / SH.[Currency Factor] ) * ( SL.[Amount Including VAT] - SL.Amount )
            END AS DECIMAL(38, 4)) AS BASE_TAX_AMOUNT,
       CAST(CASE WHEN SH.[Currency Factor] = 0 THEN SL.[Amount Including VAT]
                ELSE ( 1 / SH.[Currency Factor] ) * SL.[Amount Including VAT]
            END AS DECIMAL(38, 4)) AS BASE_GROSS_AMOUNT,
       SP.Name AS SALES_REP_NAME,
       U.[Full Name] AS CUSTOMER_SERVICE_REP_NAME,
       NULL AS VESSEL_NAME,
       SH.[Ship-to City] AS DELIVERY_LOCATION,
       SH.[Shipment Method Code] + ' - ' + SM.Description AS DELIVERY_TERMS,
       SH.[Contract No_] AS CUSTOMER_REFERENCE,
       NULL AS CANCEL_REASON,
       NULL AS PROBABILITY,
       NULL AS LOST_TO,
       NULL AS WIN_LOSE_REASON,
       CONVERT(CHAR(19), SH.[Document Date], 121) AS DATE_LAST_MODIFIED
FROM dbo.[Navision Company$Service Header] AS SH
     LEFT JOIN dbo.[Navision Company$Service Line] AS SL ON SH.[Document Type] = SL.[Document Type]
                                                            AND SH.No_ = SL.[Document No_]
     LEFT JOIN dbo.[Navision Company$General Ledger Setup] AS GLS ON 1 = 1
     LEFT JOIN dbo.[Navision Company$Salesperson_Purchaser] AS SP ON SH.[Salesperson Code] = SP.Code
     LEFT JOIN dbo.[User] AS U ON SH.[Assigned User ID] = U.[User Name]
     LEFT JOIN dbo.[Navision Company$Shipment Method] AS SM ON SH.[Shipment Method Code] = SM.Code
WHERE SH.[Document Type] = 0
      AND SL.Amount <> 0;