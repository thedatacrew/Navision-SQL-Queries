SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT I.LEGAL_ENTITY,
       I.INVOICE_ID,
       I.INVOICE_TYPE,
       I.CURRENCY,
       I.CUSTOMERID_INVOICE,
       I.CUSTOMERID_ORDER,
       I.INVOICE_NO,
       I.ORDER_REFERENCE,
       I.RMA_REFERENCE,
       I.INVOICE_DATE,
       I.SALES_TAX_AMOUNT,
       I.SALES_NET_AMOUNT,
       I.SALES_GROSS_AMOUNT,
       I.BASE_VAT_AMOUNT,
       I.BASE_NET_AMOUNT,
       I.BASE_GROSS_AMOUNT,
       I.DATE_LAST_MODIFIED,
       I.SITE
FROM( SELECT SIH.No_ AS INVOICE_ID,
             'DEBIT' AS INVOICE_TYPE,
             ISNULL(NULLIF(SIH.[Currency Code], ''), GLS.[LCY Code]) AS CURRENCY,
             SIH.[Bill-to Customer No_] AS CUSTOMERID_INVOICE,
             SIH.[Sell-to Customer No_] AS CUSTOMERID_ORDER,
             SIH.No_ AS INVOICE_NO,
             SIH.[Order No_] AS ORDER_REFERENCE,
             NULL AS RMA_REFERENCE,
             CONVERT(CHAR(10), SIH.[Document Date], 121) AS INVOICE_DATE,
             SUM(CAST(SIL.[Amount Including VAT] - SIL.Amount AS DECIMAL(38, 4))) AS SALES_TAX_AMOUNT,
             SUM(CAST(SIL.Amount AS DECIMAL(38, 4))) AS SALES_NET_AMOUNT,
             SUM(CAST(SIL.[Amount Including VAT] AS DECIMAL(38, 4))) AS SALES_GROSS_AMOUNT,
             SUM(CAST(CASE WHEN SIH.[Currency Factor] = 0 THEN SIL.[Amount Including VAT] - SIL.Amount
                          ELSE ( 1 / SIH.[Currency Factor] ) * ( SIL.[Amount Including VAT] - SIL.Amount )
                      END AS DECIMAL(38, 4))) AS BASE_VAT_AMOUNT,
             SUM(CAST(CASE WHEN SIH.[Currency Factor] = 0 THEN SIL.Amount ELSE ( 1 / SIH.[Currency Factor] ) * SIL.Amount END AS DECIMAL(38, 4))) AS BASE_NET_AMOUNT,
             SUM(CAST(CASE WHEN SIH.[Currency Factor] = 0 THEN SIL.[Amount Including VAT]
                          ELSE ( 1 / SIH.[Currency Factor] ) * SIL.[Amount Including VAT]
                      END AS DECIMAL(38, 4))) AS BASE_GROSS_AMOUNT,
             CONVERT(CHAR(19), SIH.[Posting Date], 121) AS DATE_LAST_MODIFIED,
             SIH.[Location Code] AS LOCATION_ID
      FROM [Navision Company$Sales Invoice Header] AS SIH
           LEFT OUTER JOIN dbo.[Navision Company$Sales Invoice Line] AS SIL ON SIH.No_ = SIL.[Document No_]
           OUTER APPLY dbo.[Navision Company$General Ledger Setup] AS GLS
      GROUP BY ISNULL(NULLIF(SIH.[Currency Code], ''), GLS.[LCY Code]),
               SIH.[Posting Date],
               SIH.[Document Date],
               SIH.No_,
               SIH.[Bill-to Customer No_],
               SIH.[Sell-to Customer No_],
               SIH.No_,
               SIH.[Order No_],
               SIH.[Location Code]
      UNION ALL
      SELECT SIH.No_ AS INVOICE_ID,
             'DEBIT' AS INVOICE_TYPE,
             ISNULL(NULLIF(SIH.[Currency Code], ''), GLS.[LCY Code]) AS CURRENCY,
             SIH.[Bill-to Customer No_] AS CUSTOMERID_INVOICE,
             NULL AS CUSTOMERID_ORDER,
             SIH.No_ AS INVOICE_NO,
             SIH.[Order No_] AS ORDER_REFERENCE,
             NULL AS RMA_REFERENCE,
             CONVERT(CHAR(10), SIH.[Document Date], 121) AS INVOICE_DATE,
             SUM(CAST(SIL.[Amount Including VAT] - SIL.Amount AS DECIMAL(38, 4))) AS SALES_TAX_AMOUNT,
             SUM(CAST(SIL.Amount AS DECIMAL(38, 4))) AS SALES_NET_AMOUNT,
             SUM(CAST(SIL.[Amount Including VAT] AS DECIMAL(38, 4))) AS SALES_GROSS_AMOUNT,
             SUM(CAST(CASE WHEN SIH.[Currency Factor] = 0 THEN SIL.[Amount Including VAT] - SIL.Amount
                          ELSE ( 1 / SIH.[Currency Factor] ) * ( SIL.[Amount Including VAT] - SIL.Amount )
                      END AS DECIMAL(38, 4))) AS BASE_VAT_AMOUNT,
             SUM(CAST(CASE WHEN SIH.[Currency Factor] = 0 THEN SIL.Amount ELSE ( 1 / SIH.[Currency Factor] ) * SIL.Amount END AS DECIMAL(38, 4))) AS BASE_NET_AMOUNT,
             SUM(CAST(CASE WHEN SIH.[Currency Factor] = 0 THEN SIL.[Amount Including VAT]
                          ELSE ( 1 / SIH.[Currency Factor] ) * SIL.[Amount Including VAT]
                      END AS DECIMAL(38, 4))) AS BASE_GROSS_AMOUNT,
             CONVERT(CHAR(19), SIH.[Posting Date], 121) AS DATE_LAST_MODIFIED,
             SIH.[Location Code] AS LOCATION_ID
      FROM [Navision Company$Service Invoice Header] AS SIH
           LEFT OUTER JOIN dbo.[Navision Company$Service Invoice Line] AS SIL ON SIH.No_ = SIL.[Document No_]
           OUTER APPLY dbo.[Navision Company$General Ledger Setup] AS GLS
      GROUP BY ISNULL(NULLIF(SIH.[Currency Code], ''), GLS.[LCY Code]),
               SIH.[Posting Date],
               SIH.[Document Date],
               SIH.No_,
               SIH.[Bill-to Customer No_],
               SIH.No_,
               SIH.[Order No_],
               SIH.[Location Code]
      UNION ALL
      SELECT SCH.No_ AS INVOICE_ID,
             'DEBIT' AS INVOICE_TYPE,
             ISNULL(NULLIF(SCH.[Currency Code], ''), GLS.[LCY Code]) AS CURRENCY,
             SCH.[Bill-to Customer No_] AS CUSTOMERID_INVOICE,
             SCH.[Sell-to Customer No_] AS CUSTOMERID_ORDER,
             SCH.No_ AS INVOICE_NO,
             SCH.[Return Order No_] AS ORDER_REFERENCE,
             SCH.[Return Order No_] AS RMA_REFERENCE,
             CONVERT(CHAR(10), SCH.[Document Date], 121) AS INVOICE_DATE,
             -SUM(CAST(SIL.[Amount Including VAT] - SIL.Amount AS DECIMAL(38, 4))) AS SALES_TAX_AMOUNT,
             -SUM(CAST(SIL.Amount AS DECIMAL(38, 4))) AS SALES_NET_AMOUNT,
             -SUM(CAST(SIL.[Amount Including VAT] AS DECIMAL(38, 4))) AS SALES_GROSS_AMOUNT,
             -SUM(CAST(CASE WHEN SCH.[Currency Factor] = 0 THEN SIL.[Amount Including VAT] - SIL.Amount
                           ELSE ( 1 / SCH.[Currency Factor] ) * ( SIL.[Amount Including VAT] - SIL.Amount )
                       END AS DECIMAL(38, 4))) AS BASE_VAT_AMOUNT,
             -SUM(CAST(CASE WHEN SCH.[Currency Factor] = 0 THEN SIL.Amount ELSE ( 1 / SCH.[Currency Factor] ) * SIL.Amount END AS DECIMAL(38, 4))) AS BASE_NET_AMOUNT,
             -SUM(CAST(CASE WHEN SCH.[Currency Factor] = 0 THEN SIL.[Amount Including VAT]
                           ELSE ( 1 / SCH.[Currency Factor] ) * SIL.[Amount Including VAT]
                       END AS DECIMAL(38, 4))) AS BASE_GROSS_AMOUNT,
             CONVERT(CHAR(19), SCH.[Posting Date], 121) AS DATE_LAST_MODIFIED,
             SCH.[Location Code] AS LOCATION_ID
      FROM [Navision Company$Sales Cr_Memo Header] AS SCH
           LEFT OUTER JOIN dbo.[Navision Company$Sales Cr_Memo Line] AS SIL ON SCH.No_ = SIL.[Document No_]
           OUTER APPLY dbo.[Navision Company$General Ledger Setup] AS GLS
      GROUP BY ISNULL(NULLIF(SCH.[Currency Code], ''), GLS.[LCY Code]),
               SCH.[Posting Date],
               SCH.[Document Date],
               SCH.No_,
               SCH.[Bill-to Customer No_],
               SCH.[Sell-to Customer No_],
               SCH.No_,
               SCH.[Return Order No_],
               SCH.[Return Order No_],
               SCH.[Location Code]
      UNION ALL
      SELECT SCH.No_ AS INVOICE_ID,
             'DEBIT' AS INVOICE_TYPE,
             ISNULL(NULLIF(SCH.[Currency Code], ''), GLS.[LCY Code]) AS CURRENCY,
             SCH.[Bill-to Customer No_] AS CUSTOMERID_INVOICE,
             NULL AS CUSTOMERID_ORDER,
             SCH.No_ AS INVOICE_NO,
             NULL AS ORDER_REFERENCE,
             NULL AS RMA_REFERENCE,
             CONVERT(CHAR(10), SCH.[Document Date], 121) AS INVOICE_DATE,
             -SUM(CAST(SIL.[Amount Including VAT] - SIL.Amount AS DECIMAL(38, 4))) AS SALES_TAX_AMOUNT,
             -SUM(CAST(SIL.Amount AS DECIMAL(38, 4))) AS SALES_NET_AMOUNT,
             -SUM(CAST(SIL.[Amount Including VAT] AS DECIMAL(38, 4))) AS SALES_GROSS_AMOUNT,
             -SUM(CAST(CASE WHEN SCH.[Currency Factor] = 0 THEN SIL.[Amount Including VAT] - SIL.Amount
                           ELSE ( 1 / SCH.[Currency Factor] ) * ( SIL.[Amount Including VAT] - SIL.Amount )
                       END AS DECIMAL(38, 4))) AS BASE_VAT_AMOUNT,
             -SUM(CAST(CASE WHEN SCH.[Currency Factor] = 0 THEN SIL.Amount ELSE ( 1 / SCH.[Currency Factor] ) * SIL.Amount END AS DECIMAL(38, 4))) AS BASE_NET_AMOUNT,
             -SUM(CAST(CASE WHEN SCH.[Currency Factor] = 0 THEN SIL.[Amount Including VAT]
                           ELSE ( 1 / SCH.[Currency Factor] ) * SIL.[Amount Including VAT]
                       END AS DECIMAL(38, 4))) AS BASE_GROSS_AMOUNT,
             CONVERT(CHAR(19), SCH.[Posting Date], 121) AS DATE_LAST_MODIFIED,
             SCH.[Location Code] AS LOCATION_ID
      FROM [Navision Company$Service Cr_Memo Header] AS SCH
           LEFT OUTER JOIN dbo.[Navision Company$Service Cr_Memo Line] AS SIL ON SCH.No_ = SIL.[Document No_]
           OUTER APPLY dbo.[Navision Company$General Ledger Setup] AS GLS
      GROUP BY ISNULL(NULLIF(SCH.[Currency Code], ''), GLS.[LCY Code]),
               SCH.[Posting Date],
               SCH.[Document Date],
               SCH.No_,
               SCH.[Bill-to Customer No_],
               SCH.No_,
               SCH.[Location Code] ) AS I;



