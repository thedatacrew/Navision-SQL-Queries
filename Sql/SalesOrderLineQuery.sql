SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    /*** Sales Orders ***/
    CAST(SL.[Document Type] AS VARCHAR(32)) + '-' + SL.[Document No_] + '-' + CAST(SL.[Line No_] AS VARCHAR(32)) AS SALES_ORDER_LINE_ID,
    SH.[Bill-to Customer No_] AS CUSTOMERID_INVOICE,
    SH.[Sell-to Customer No_] AS CUSTOMERID_ORDER,
    ISNULL(NULLIF(SH.[Currency Code], N''), GLS.[LCY Code]) AS CURRENCY_ID,
    SL.No_ AS ITEM_ID,
    CAST(SL.[Document Type] AS VARCHAR(32)) + '-' + SL.[Document No_] AS SALES_ORDER_ID,
    CASE WHEN SL.[Location Code] <> '' THEN SL.[Location Code]
        WHEN SL.[Location Code] = ''
             AND SH.[Location Code] <> '' THEN SH.[Location Code]
    END AS LOCATION_ID,
    SH.[Salesperson Code] AS SALES_REP_ID,
    SUBSTRING(SH.[Assigned User ID], CHARINDEX('\', SH.[Assigned User ID]) + 1, 50) AS CUSTOMER_SERVICE_REP_ID,
    SL.[Line No_] AS LINE_NUMBER,
    NULL AS DELIVERY_NUMBER,
    CASE WHEN SH.[Document Type] = 1 THEN 'Sales Order'
        WHEN SH.[Document Type] = 5 THEN 'Sales Return'
    END AS SALES_ORDER_TYPE,
    CONVERT(CHAR(10), SH.[Order Date], 121) AS ORDER_DATE,
    CASE WHEN SH.Status = 0 THEN 'Planned'
        WHEN SH.Status = 1 THEN 'Released'
        WHEN SH.Status = 2 THEN 'Released'
        WHEN SH.Status = 3 THEN 'Released'
        WHEN SH.Status = 4 THEN 'Invoiced/Closed'
        WHEN SH.Status = 5 THEN 'Invoiced/Closed'
        WHEN SH.Status = 7 THEN 'Cancelled'
        ELSE 'Unknown'
    END AS ORDER_STATUS,
    CASE WHEN SH.Status = 0 THEN 'Planned'
        WHEN SH.Status = 1 THEN 'Released'
        WHEN SH.Status = 2 THEN 'Released'
        WHEN SH.Status = 3 THEN 'Released'
        WHEN SH.Status = 4 THEN 'Invoiced/Closed'
        WHEN SH.Status = 5 THEN 'Invoiced/Closed'
        WHEN SH.Status = 7 THEN 'Cancelled'
        ELSE 'Unknown'
    END AS LINE_STATUS,
    SL.Description AS DESCRIPTION,
    CAST(SL.Quantity AS DECIMAL(38, 4)) AS QUANTITY_ORDERED,
    CAST(SL.[Quantity Invoiced] AS DECIMAL(38, 4)) AS QUANTITY_INVOICED,
    CAST(SL.[Outstanding Quantity] AS DECIMAL(38, 4)) AS QUANTITY_OUTSTANDING,
    SL.[Unit of Measure] AS UNIT_OF_MEASURE,
    SH.[VAT Bus_ Posting Group] AS TAX_CODE,
    CAST(SL.[VAT _] AS DECIMAL(38, 4)) AS TAX_RATE,
    SL.[Requested Delivery Date] AS DATE_DELIVERY_REQUIRED,
    SL.[Planned Shipment Date] AS DATE_SHIPMENT_PLANNED,
    SH.[Shipment Date] AS DATE_SHIPPED,
    CAST(0 AS DECIMAL(38, 4)) AS ORDER_DISCOUNT_RATE,
    CAST(SL.[Line Discount _] AS DECIMAL(38, 4)) AS LINE_DISCOUNT_RATE,
    CAST(SL.[Line Discount _] AS DECIMAL(38, 4)) AS TOTAL_DISCOUNT_RATE,
    CAST(SL.[Unit Cost] AS DECIMAL(38, 4)) AS SALES_UNIT_COST,
    CAST(SL.[Unit Price] AS DECIMAL(38, 4)) AS SALES_UNIT_PRICE,
    CAST(SL.Amount AS DECIMAL(38, 4)) AS SALES_NET_AMOUNT,
    CAST(SL.[Line Discount Amount] AS DECIMAL(38, 4)) AS SALES_DISCOUNT_AMOUNT,
    CAST(SL.[Amount Including VAT] - SL.Amount AS DECIMAL(38, 4)) AS SALES_TAX_AMOUNT,
    CAST(SL.[Amount Including VAT] AS DECIMAL(38, 4)) AS SALES_GROSS_AMOUNT,
    CAST(SL.[Unit Cost (LCY)] AS DECIMAL(38, 4)) AS BASE_UNIT_COST,
    CAST(( CASE WHEN SH.[Currency Factor] = 0 THEN SL.[Unit Price]
               ELSE ( 1 / SH.[Currency Factor] ) * SL.[Unit Price]
           END ) AS DECIMAL(38, 4)) AS BASE_UNIT_PRICE,
    CAST(CASE WHEN SH.[Currency Factor] = 0 THEN SL.Amount ELSE ( 1 / SH.[Currency Factor] ) * SL.Amount END AS DECIMAL(38, 4)) AS BASE_NET_AMOUNT,
    CAST(CASE WHEN SH.[Currency Factor] = 0 THEN SL.[Line Discount Amount]
             ELSE ( 1 / SH.[Currency Factor] ) * SL.[Line Discount Amount]
         END AS DECIMAL(38, 4)) AS BASE_DISCOUNT_AMOUNT,
    CAST(CASE WHEN SH.[Currency Factor] = 0 THEN SL.[Amount Including VAT] - SL.Amount
             ELSE ( 1 / SH.[Currency Factor] ) * ( SL.[Amount Including VAT] - SL.Amount )
         END AS DECIMAL(38, 4)) AS BASE_TAX_AMOUNT,
    CAST(CASE WHEN SH.[Currency Factor] = 0 THEN SL.[Amount Including VAT]
             ELSE ( 1 / SH.[Currency Factor] ) * SL.[Amount Including VAT]
         END AS DECIMAL(38, 4)) AS BASE_GROSS_AMOUNT,
    CAST(SL.[Outstanding Amount] AS DECIMAL(38, 4)) AS SALES_NET_AMOUNT_OUTSTANDING,
    CAST(SL.[Outstanding Amount (LCY)] AS DECIMAL(38, 4)) AS BASE_NET_AMOUNT_OUTSTANDING,
    NULL AS SOURCE_PRICE,
    NULL AS PRICE_SOURCE,
    SP.Name AS SALES_REP_NAME,
    U.[Full Name] AS CUSTOMER_SERVICE_REP_NAME,
    NULL AS VESSEL_NAME,
    SH.[Ship-to City] AS DEL_LOCATION,
    SH.[Shipment Method Code] + ' - ' + SM.Description AS DELIVERY_TERMS,
    SH.[External Document No_] AS CUST_REF,
    NULL AS CANCEL_REASON,
    CONVERT(CHAR(19), SH.[Document Date], 121) AS DATE_LAST_MODIFIED
FROM dbo.[Navision Company$Sales Header] AS SH
     LEFT OUTER JOIN dbo.[Navision Company$Sales Line] AS SL ON SH.[Document Type] = SL.[Document Type]
                                                                AND SH.No_ = SL.[Document No_]
     OUTER APPLY dbo.[Navision Company$General Ledger Setup] AS GLS
     LEFT OUTER JOIN dbo.[Navision Company$Salesperson_Purchaser] AS SP ON SP.Code = SH.[Salesperson Code]
     LEFT OUTER JOIN dbo.[Navision Company$Shipment Method] AS SM ON SM.Code = SH.[Shipment Method Code]
     LEFT OUTER JOIN dbo.[User] AS U ON SH.[Assigned User ID] = U.[User Name]
WHERE SH.[Document Type] IN ( 1, 5 )
      AND SL.Amount <> 0
UNION ALL
SELECT
    /*** Service Orders ***/
    CAST(SL.[Document Type] AS VARCHAR(32)) + '-' + SL.[Document No_] + '-' + CAST(SL.[Line No_] AS VARCHAR(32)) AS SALES_ORDER_LINE_ID,
    SH.[Bill-to Customer No_] AS CUSTOMERID_INVOICE,
    SH.[Bill-to Customer No_] AS CUSTOMERID_ORDER,
    ISNULL(NULLIF(SH.[Currency Code], N''), GLS.[LCY Code]) AS CURRENCY_ID,
    SL.No_ AS ITEM_ID,
    CAST(SL.[Document Type] AS VARCHAR(32)) + '-' + SL.[Document No_] AS SALES_ORDER_ID,
    CASE WHEN SL.[Location Code] <> '' THEN SL.[Location Code]
        WHEN SL.[Location Code] = ''
             AND SH.[Location Code] <> '' THEN SH.[Location Code]
    END AS LOCATION_ID,
    SH.[Salesperson Code] AS SALES_REP_ID,
    SUBSTRING(SH.[Assigned User ID], CHARINDEX('\', SH.[Assigned User ID]) + 1, 50) AS CUSTOMER_SERVICE_REP_ID,
    SL.[Line No_] AS LINE_NUMBER,
    NULL AS DELIVERY_NUMBER,
    CASE WHEN SH.[Document Type] = 1 THEN 'Service Sales Order'
        WHEN SH.[Document Type] = 5 THEN 'Service Sales Return'
    END AS SALES_ORDER_TYPE,
    CONVERT(CHAR(10), SH.[Order Date], 121) AS ORDER_DATE,
    CASE WHEN SH.Status = 0 THEN 'Planned'
        WHEN SH.Status = 1 THEN 'Released'
        WHEN SH.Status = 2 THEN 'Released'
        WHEN SH.Status = 3 THEN 'Released'
        WHEN SH.Status = 4 THEN 'Invoiced/Closed'
        WHEN SH.Status = 5 THEN 'Invoiced/Closed'
        WHEN SH.Status = 7 THEN 'Cancelled'
        ELSE 'Unknown'
    END AS ORDER_STATUS,
    CASE WHEN SH.Status = 0 THEN 'Planned'
        WHEN SH.Status = 1 THEN 'Released'
        WHEN SH.Status = 2 THEN 'Released'
        WHEN SH.Status = 3 THEN 'Released'
        WHEN SH.Status = 4 THEN 'Invoiced/Closed'
        WHEN SH.Status = 5 THEN 'Invoiced/Closed'
        WHEN SH.Status = 7 THEN 'Cancelled'
        ELSE 'Unknown'
    END AS LINE_STATUS,
    SL.Description AS DESCRIPTION,
    CAST(SL.Quantity AS DECIMAL(38, 4)) AS QUANTITY_ORDERED,
    CAST(SL.[Quantity Invoiced] AS DECIMAL(38, 4)) AS QUANTITY_INVOICED,
    CAST(SL.[Outstanding Quantity] AS DECIMAL(38, 4)) AS QUANTITY_OUTSTANDING,
    SL.[Unit of Measure] AS UNIT_OF_MEASURE,
    SH.[VAT Bus_ Posting Group] AS TAX_CODE,
    CAST(SL.[VAT _] AS DECIMAL(38, 4)) AS TAX_RATE,
    SL.[Requested Delivery Date] AS DATE_DELIVERY_REQUIRED,
    SH.[Expected Finishing Date] AS DATE_SHIPMENT_PLANNED,
    SH.[Finishing Date] AS DATE_SHIPPED,
    CAST(0 AS DECIMAL(38, 4)) AS ORDER_DISCOUNT_RATE,
    CAST(SL.[Line Discount _] AS DECIMAL(38, 4)) AS LINE_DISCOUNT_RATE,
    CAST(SL.[Line Discount _] AS DECIMAL(38, 4)) AS TOTAL_DISCOUNT_RATE,
    CAST(SL.[Unit Cost] AS DECIMAL(38, 4)) AS SALES_UNIT_COST,
    CAST(SL.[Unit Price] AS DECIMAL(38, 4)) AS SALES_UNIT_PRICE,
    CAST(SL.Amount AS DECIMAL(38, 4)) AS SALES_NET_AMOUNT,
    CAST(SL.[Line Discount Amount] AS DECIMAL(38, 4)) AS SALES_DISCOUNT_AMOUNT,
    CAST(SL.[Amount Including VAT] - SL.Amount AS DECIMAL(38, 4)) AS SALES_TAX_AMOUNT,
    CAST(SL.[Amount Including VAT] AS DECIMAL(38, 4)) AS SALES_GROSS_AMOUNT,
    CAST(SL.[Unit Cost (LCY)] AS DECIMAL(38, 4)) AS BASE_UNIT_COST,
    CAST(( CASE WHEN SH.[Currency Factor] = 0 THEN SL.[Unit Price]
               ELSE ( 1 / SH.[Currency Factor] ) * SL.[Unit Price]
           END ) AS DECIMAL(38, 4)) AS BASE_UNIT_PRICE,
    CAST(CASE WHEN SH.[Currency Factor] = 0 THEN SL.Amount ELSE ( 1 / SH.[Currency Factor] ) * SL.Amount END AS DECIMAL(38, 4)) AS BASE_NET_AMOUNT,
    CAST(CASE WHEN SH.[Currency Factor] = 0 THEN SL.[Line Discount Amount]
             ELSE ( 1 / SH.[Currency Factor] ) * SL.[Line Discount Amount]
         END AS DECIMAL(38, 4)) AS BASE_DISCOUNT_AMOUNT,
    CAST(CASE WHEN SH.[Currency Factor] = 0 THEN SL.[Amount Including VAT] - SL.Amount
             ELSE ( 1 / SH.[Currency Factor] ) * ( SL.[Amount Including VAT] - SL.Amount )
         END AS DECIMAL(38, 4)) AS BASE_TAX_AMOUNT,
    CAST(CASE WHEN SH.[Currency Factor] = 0 THEN SL.[Amount Including VAT]
             ELSE ( 1 / SH.[Currency Factor] ) * SL.[Amount Including VAT]
         END AS DECIMAL(38, 4)) AS BASE_GROSS_AMOUNT,
    CAST(SL.[Outstanding Amount] AS DECIMAL(38, 4)) AS SALES_NET_AMOUNT_OUTSTANDING,
    CAST(SL.[Outstanding Amount (LCY)] AS DECIMAL(38, 4)) AS BASE_NET_AMOUNT_OUTSTANDING,
    NULL AS SOURCE_PRICE,
    NULL AS PRICE_SOURCE,
    SP.Name AS SALES_REP_NAME,
    U.[Full Name] AS CUSTOMER_SERVICE_REP_NAME,
    NULL AS VESSEL_NAME,
    SH.[Ship-to City] AS DEL_LOCATION,
    SH.[Shipment Method Code] + ' - ' + SM.Description AS DELIVERY_TERMS,
    SH.[Contract No_] AS CUST_REF,
    NULL AS CANCEL_REASON,
    CONVERT(CHAR(19), SH.[Document Date], 121) AS DATE_LAST_MODIFIED
FROM dbo.[Navision Company$Service Header] AS SH
     LEFT OUTER JOIN dbo.[Navision Company$Service Line] AS SL ON SH.[Document Type] = SL.[Document Type]
                                                                  AND SH.No_ = SL.[Document No_]
     OUTER APPLY dbo.[Navision Company$General Ledger Setup] AS GLS
     LEFT OUTER JOIN dbo.[Navision Company$Salesperson_Purchaser] AS SP ON SP.Code = SH.[Salesperson Code]
     LEFT OUTER JOIN dbo.[Navision Company$Shipment Method] AS SM ON SM.Code = SH.[Shipment Method Code]
     LEFT OUTER JOIN dbo.[User] AS U ON SH.[Assigned User ID] = U.[User Name]
WHERE SH.[Document Type] IN ( 1, 5 )
      AND SL.Amount <> 0;

