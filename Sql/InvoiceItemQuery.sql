SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT II.LEGAL_ENTITY,
       II.INVOICE_ID,
       II.CUSTOMERID_INVOICE,
       II.QUANTITY,
       II.SALE_UNIT_PRICE,
       II.TAX_RATE,
       II.SALES_DISCOUNT,
       II.SALES_TAX_AMOUNT,
       II.SALES_NET_AMOUNT,
       II.SALES_GROSS_AMOUNT,
       II.BASE_SALE_UNIT_PRICE,
       II.BASE_VAT_AMOUNT,
       II.BASE_NET_AMOUNT,
       II.BASE_GROSS_AMOUNT,
       II.DATE_LAST_MODIFIED,
       II.INVOICE_ITEM_ID,
       II.LINE_NO,
       II.SITE,
       II.PART_CODE,
       II.DESCRIPTION,
       II.CATEGORY,
       II.UOM
FROM( SELECT SIL.[Document No_] AS INVOICE_ID,
             CONVERT(CHAR(10), SIH.[Document Date], 121) AS INVOICE_DATE,
             ISNULL(NULLIF(SIL.[Sell-to Customer No_], ''), SIH.[Bill-to Customer No_]) AS CUSTOMERID_INVOICE,
             CAST(SIL.Quantity AS DECIMAL(38, 4)) AS QUANTITY,
             CAST(SIL.[Unit Price] AS DECIMAL(38, 4)) AS SALE_UNIT_PRICE,
             CAST(SIL.[VAT _] AS DECIMAL(38, 4)) AS TAX_RATE,
             CAST(SIL.[Line Discount _] AS DECIMAL(38, 4)) AS SALES_DISCOUNT,
             CAST(SIL.[Amount Including VAT] - SIL.Amount AS DECIMAL(38, 4)) AS SALES_TAX_AMOUNT,
             CAST(SIL.Amount AS DECIMAL(38, 4)) AS SALES_NET_AMOUNT,
             CAST(SIL.[Amount Including VAT] AS DECIMAL(38, 4)) AS SALES_GROSS_AMOUNT,
             CAST(CASE WHEN SIH.[Currency Factor] = 0 THEN SIL.[Unit Price]
                      ELSE ( 1 / SIH.[Currency Factor] ) * ( SIL.[Unit Price] )
                  END AS DECIMAL(38, 4)) AS BASE_SALE_UNIT_PRICE,
             CAST(CASE WHEN SIH.[Currency Factor] = 0 THEN SIL.[Amount Including VAT] - SIL.Amount
                      ELSE ( 1 / SIH.[Currency Factor] ) * ( SIL.[Amount Including VAT] - SIL.Amount )
                  END AS DECIMAL(38, 4)) AS BASE_VAT_AMOUNT,
             CAST(CASE WHEN SIH.[Currency Factor] = 0 THEN SIL.Amount ELSE ( 1 / SIH.[Currency Factor] ) * SIL.Amount END AS DECIMAL(38, 4)) AS BASE_NET_AMOUNT,
             CAST(CASE WHEN SIH.[Currency Factor] = 0 THEN SIL.[Amount Including VAT]
                      ELSE ( 1 / SIH.[Currency Factor] ) * SIL.[Amount Including VAT]
                  END AS DECIMAL(38, 4)) AS BASE_GROSS_AMOUNT,
             CONVERT(CHAR(19), SIL.[Posting Date], 121) AS DATE_LAST_MODIFIED,
             SIL.[Document No_] + '-' + CAST(SIL.[Line No_] AS VARCHAR(16)) AS INVOICE_ITEM_ID,
             SIL.[Line No_] AS LINE_NO,
             SIL.[Location Code] AS LOCATION_ID,
             SIL.No_ AS PART_CODE,
             SIL.Description AS DESCRIPTION,
             SIL.[Item Category Code] AS CATEGORY,
             SIL.[Unit of Measure] AS UOM
      FROM [Navision Company$Sales Invoice Header] AS SIH
           LEFT OUTER JOIN dbo.[Navision Company$Sales Invoice Line] AS SIL ON SIH.No_ = SIL.[Document No_]
      UNION ALL
      SELECT SIL.[Document No_] AS INVOICE_ID,
             CONVERT(CHAR(10), SIH.[Document Date], 121) AS INVOICE_DATE,
             SIH.[Bill-to Customer No_] AS CUSTOMERID_INVOICE,
             CAST(SIL.Quantity AS DECIMAL(38, 4)) AS QUANTITY,
             CAST(SIL.[Unit Price] AS DECIMAL(38, 4)) AS SALE_UNIT_PRICE,
             CAST(SIL.[VAT _] AS DECIMAL(38, 4)) AS TAX_RATE,
             CAST(SIL.[Line Discount _] AS DECIMAL(38, 4)) AS SALES_DISCOUNT,
             CAST(SIL.[Amount Including VAT] - SIL.Amount AS DECIMAL(38, 4)) AS SALES_TAX_AMOUNT,
             CAST(SIL.Amount AS DECIMAL(38, 4)) AS SALES_NET_AMOUNT,
             CAST(SIL.[Amount Including VAT] AS DECIMAL(38, 4)) AS SALES_GROSS_AMOUNT,
             CAST(CASE WHEN SIH.[Currency Factor] = 0 THEN SIL.[Unit Price]
                      ELSE ( 1 / SIH.[Currency Factor] ) * ( SIL.[Unit Price] )
                  END AS DECIMAL(38, 4)) AS BASE_SALE_UNIT_PRICE,
             CAST(CASE WHEN SIH.[Currency Factor] = 0 THEN SIL.[Amount Including VAT] - SIL.Amount
                      ELSE ( 1 / SIH.[Currency Factor] ) * ( SIL.[Amount Including VAT] - SIL.Amount )
                  END AS DECIMAL(38, 4)) AS BASE_VAT_AMOUNT,
             CAST(CASE WHEN SIH.[Currency Factor] = 0 THEN SIL.Amount ELSE ( 1 / SIH.[Currency Factor] ) * SIL.Amount END AS DECIMAL(38, 4)) AS BASE_NET_AMOUNT,
             CAST(CASE WHEN SIH.[Currency Factor] = 0 THEN SIL.[Amount Including VAT]
                      ELSE ( 1 / SIH.[Currency Factor] ) * SIL.[Amount Including VAT]
                  END AS DECIMAL(38, 4)) AS BASE_GROSS_AMOUNT,
             CONVERT(CHAR(19), SIL.[Posting Date], 121) AS DATE_LAST_MODIFIED,
             SIL.[Document No_] + '-' + CAST(SIL.[Line No_] AS VARCHAR(16)) AS INVOICE_ITEM_ID,
             SIL.[Line No_] AS LINE_NO,
             SIL.[Location Code] AS LOCATION_ID,
             SIL.No_ AS PART_CODE,
             SIL.Description AS DESCRIPTION,
             SIL.[Item Category Code] AS CATEGORY,
             SIL.[Unit of Measure] AS UOM
      FROM [Navision Company$Service Invoice Header] AS SIH
           LEFT OUTER JOIN dbo.[Navision Company$Service Invoice Line] AS SIL ON SIH.No_ = SIL.[Document No_]
      UNION ALL
      SELECT SCL.[Document No_] AS INVOICE_ID,
             CONVERT(CHAR(10), SCH.[Document Date], 121) AS INVOICE_DATE,
             ISNULL(NULLIF(SCL.[Sell-to Customer No_], ''), SCH.[Bill-to Customer No_]) AS CUSTOMERID_INVOICE,
             CAST(SCL.Quantity AS DECIMAL(38, 4)) AS QUANTITY,
             CAST(SCL.[Unit Price] AS DECIMAL(38, 4)) AS SALE_UNIT_PRICE,
             CAST(SCL.[VAT _] AS DECIMAL(38, 4)) AS TAX_RATE,
             CAST(SCL.[Line Discount _] AS DECIMAL(38, 4)) AS SALES_DISCOUNT,
             -CAST(SCL.[Amount Including VAT] - SCL.Amount AS DECIMAL(38, 4)) AS SALES_TAX_AMOUNT,
             -CAST(SCL.Amount AS DECIMAL(38, 4)) AS SALES_NET_AMOUNT,
             -CAST(SCL.[Amount Including VAT] AS DECIMAL(38, 4)) AS SALES_GROSS_AMOUNT,
             CAST(CASE WHEN SCH.[Currency Factor] = 0 THEN SCL.[Unit Price]
                      ELSE ( 1 / SCH.[Currency Factor] ) * ( SCL.[Unit Price] )
                  END AS DECIMAL(38, 4)) AS BASE_SALE_UNIT_PRICE,
             -CAST(CASE WHEN SCH.[Currency Factor] = 0 THEN SCL.[Amount Including VAT] - SCL.Amount
                       ELSE ( 1 / SCH.[Currency Factor] ) * ( SCL.[Amount Including VAT] - SCL.Amount )
                   END AS DECIMAL(38, 4)) AS BASE_VAT_AMOUNT,
             -CAST(CASE WHEN SCH.[Currency Factor] = 0 THEN SCL.Amount ELSE ( 1 / SCH.[Currency Factor] ) * SCL.Amount END AS DECIMAL(38, 4)) AS BASE_NET_AMOUNT,
             -CAST(CASE WHEN SCH.[Currency Factor] = 0 THEN SCL.[Amount Including VAT]
                       ELSE ( 1 / SCH.[Currency Factor] ) * SCL.[Amount Including VAT]
                   END AS DECIMAL(38, 4)) AS BASE_GROSS_AMOUNT,
             CONVERT(CHAR(19), SCL.[Posting Date], 121) AS DATE_LAST_MODIFIED,
             SCL.[Document No_] + '-' + CAST(SCL.[Line No_] AS VARCHAR(16)) AS INVOICE_ITEM_ID,
             SCL.[Line No_] AS LINE_NO,
             SCL.[Location Code] AS LOCATION_ID,
             SCL.No_ AS PART_CODE,
             SCL.Description AS DESCRIPTION,
             SCL.[Item Category Code] AS CATEGORY,
             SCL.[Unit of Measure] AS UOM
      FROM dbo.[Navision Company$Sales Cr_Memo Header] AS SCH
           LEFT OUTER JOIN dbo.[Navision Company$Sales Cr_Memo Line] AS SCL ON SCH.No_ = SCL.[Document No_]
      UNION ALL
      SELECT SCL.[Document No_] AS INVOICE_ID,
             CONVERT(CHAR(10), SCH.[Document Date], 121) AS INVOICE_DATE,
             SCH.[Bill-to Customer No_] AS CUSTOMERID_INVOICE,
             CAST(SCL.Quantity AS DECIMAL(38, 4)) AS QUANTITY,
             CAST(SCL.[Unit Price] AS DECIMAL(38, 4)) AS SALE_UNIT_PRICE,
             CAST(SCL.[VAT _] AS DECIMAL(38, 4)) AS TAX_RATE,
             CAST(SCL.[Line Discount _] AS DECIMAL(38, 4)) AS SALES_DISCOUNT,
             -CAST(SCL.[Amount Including VAT] - SCL.Amount AS DECIMAL(38, 4)) AS SALES_TAX_AMOUNT,
             -CAST(SCL.Amount AS DECIMAL(38, 4)) AS SALES_NET_AMOUNT,
             -CAST(SCL.[Amount Including VAT] AS DECIMAL(38, 4)) AS SALES_GROSS_AMOUNT,
             CAST(CASE WHEN SCH.[Currency Factor] = 0 THEN SCL.[Unit Price]
                      ELSE ( 1 / SCH.[Currency Factor] ) * ( SCL.[Unit Price] )
                  END AS DECIMAL(38, 4)) AS BASE_SALE_UNIT_PRICE,
             -CAST(CASE WHEN SCH.[Currency Factor] = 0 THEN SCL.[Amount Including VAT] - SCL.Amount
                       ELSE ( 1 / SCH.[Currency Factor] ) * ( SCL.[Amount Including VAT] - SCL.Amount )
                   END AS DECIMAL(38, 4)) AS BASE_VAT_AMOUNT,
             -CAST(CASE WHEN SCH.[Currency Factor] = 0 THEN SCL.Amount ELSE ( 1 / SCH.[Currency Factor] ) * SCL.Amount END AS DECIMAL(38, 4)) AS BASE_NET_AMOUNT,
             -CAST(CASE WHEN SCH.[Currency Factor] = 0 THEN SCL.[Amount Including VAT]
                       ELSE ( 1 / SCH.[Currency Factor] ) * SCL.[Amount Including VAT]
                   END AS DECIMAL(38, 4)) AS BASE_GROSS_AMOUNT,
             CONVERT(CHAR(19), SCL.[Posting Date], 121) AS DATE_LAST_MODIFIED,
             SCL.[Document No_] + '-' + CAST(SCL.[Line No_] AS VARCHAR(16)) AS INVOICE_ITEM_ID,
             SCL.[Line No_] AS LINE_NO,
             SCL.[Location Code] AS LOCATION_ID,
             SCL.No_ AS PART_CODE,
             SCL.Description AS DESCRIPTION,
             SCL.[Item Category Code] AS CATEGORY,
             SCL.[Unit of Measure] AS UOM
      FROM dbo.[Navision Company$Service Cr_Memo Header] AS SCH
           LEFT OUTER JOIN dbo.[Navision Company$Service Cr_Memo Line] AS SCL ON SCH.No_ = SCL.[Document No_] ) AS II;
