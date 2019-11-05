SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT CLE.[Entry No_] AS INVOICE_LEDGER_ID,
       ISNULL(NULLIF(CLE.[Currency Code], N''), GLS.[LCY Code]) AS CURRENCY,
       ISNULL(NULLIF(CLE.[Customer No_], ''), CLE.[Sell-to Customer No_]) AS CUSTOMER_ID,
       CLE.[Document No_] AS INVOICE_ID,
       CASE WHEN CLE.[Document Type] = 2 THEN 'DEBIT'
           WHEN CLE.[Document Type] = 3 THEN 'CREDIT'
           ELSE NULL
       END AS INVOICE_TYPE,
       CLE.[Document No_] AS INVOICE_NO,
       CONVERT(CHAR(10), CLE.[Document Date], 121) AS INVOICE_DATE,
       SIH.[Payment Terms Code] AS PAYMENT_TERMS,
       SDPT.Description AS PAYMENT_TERMS_DESCRIPTION,
       CONVERT(CHAR(10), CLE.[Due Date], 121) AS DUE_DATE,
       CONVERT(CHAR(10), NULLIF(CLE.[Closed at Date], N'1753-01-01 00:00:00.000'), 121) AS PAID_DATE,
       CAST(SIL.InvoiceTotal AS DECIMAL(38, 4)) AS SALES_INVOICE_AMOUNT,
       CAST(CLE.[Closed by Amount] AS DECIMAL(38, 4)) AS SALES_PAID_AMOUNT,
       CASE WHEN CAST(SIL.InvoiceTotal - CLE.[Closed by Amount] AS DECIMAL(38, 4)) <= 0 THEN CAST(0 AS DECIMAL(38, 4))
           ELSE CAST(SIL.InvoiceTotal - CLE.[Closed by Amount] AS DECIMAL(38, 4))
       END AS SALES_DUE_AMOUNT,
       CAST(CASE WHEN CLE.[Adjusted Currency Factor] = 0 THEN SIL.InvoiceTotal
                ELSE ( 1 / CLE.[Adjusted Currency Factor] ) * SIL.InvoiceTotal
            END AS DECIMAL(38, 4)) AS BASE_INVOICE_AMOUNT,
       CAST(CASE WHEN CLE.[Adjusted Currency Factor] = 0 THEN CLE.[Closed by Amount]
                ELSE CLE.[Closed by Amount (LCY)]
            END AS DECIMAL(38, 4)) AS BASE_PAID_AMOUNT,
       CASE WHEN CAST(SIL.InvoiceTotal - CLE.[Closed by Amount] AS DECIMAL(38, 4)) <= 0 THEN CAST(0 AS DECIMAL(38, 4))
           ELSE CAST(CASE WHEN CLE.[Adjusted Currency Factor] = 0 THEN ( SIL.InvoiceTotal - CLE.[Closed by Amount] )
                         ELSE ( SIL.InvoiceTotal - CLE.[Closed by Amount (LCY)] )
                     END AS DECIMAL(38, 4))
       END AS BASE_DUE_AMOUNT,
       CASE WHEN SIL.InvoiceTotal - CLE.[Closed by Amount] <= 0
                 AND [Open] = 0 THEN 1
           WHEN SIL.InvoiceTotal IS NULL
                AND [Open] = 0 THEN 1
           ELSE 0
       END AS IS_FULLY_PAID,
       CLE.[Document No_] AS PAYMENT_REFERENCE,
       CONVERT(CHAR(19), CLE.[Posting Date], 121) AS DATE_LAST_MODIFIED
FROM dbo.[Navision Company$Cust_ Ledger Entry] AS CLE
     LEFT OUTER JOIN dbo.[Navision Company$Sales Invoice Header] AS SIH ON CLE.[Document No_] = SIH.No_
     LEFT OUTER JOIN( SELECT [Document No_],
                             SUM([Amount Including VAT]) AS InvoiceTotal
                      FROM dbo.[Navision Company$Sales Invoice Line]
                      GROUP BY [Document No_] ) AS SIL ON SIL.[Document No_] = SIH.No_
     LEFT OUTER JOIN dbo.[Navision Company$Customer] AS SDC ON CLE.[Customer No_] = SDC.No_
     LEFT OUTER JOIN dbo.[Navision Company$Payment Terms] AS SDPT ON SIH.[Payment Terms Code] = SDPT.Code
     OUTER APPLY dbo.[Navision Company$General Ledger Setup] AS GLS
WHERE( CLE.[Document Type] IN ( 2, 3 ))
     AND ( CLE.[Sales (LCY)] <> 0 );