;WITH
I   AS
( SELECT SIH.No_,
         SIH.[Payment Terms Code],
         2 AS DocumentType
  FROM dbo.[Navision Company$Sales Invoice Header] AS SIH
  UNION
  SELECT SCMH.No_,
         SCMH.[Payment Terms Code],
         3 AS DocumentType
  FROM dbo.[Navision Company$Sales Cr_Memo Header] AS SCMH
  UNION
  SELECT SIH.No_,
         SIH.[Payment Terms Code],
         2 AS DocumentType
  FROM dbo.[Navision Company$Service Invoice Header] AS SIH
  UNION
  SELECT SCMH.No_,
         SCMH.[Payment Terms Code],
         3 AS DocumentType
  FROM dbo.[Navision Company$Service Cr_Memo Header] AS SCMH ),
PT  AS
( SELECT PT.Code, PT.Description FROM dbo.[Navision Company$Payment Terms] AS PT )
SELECT DCLE.[Entry No_] AS CUSTOMER_LEDGER_TRASANCTION_ID,
       DCLE.[Cust_ Ledger Entry No_] AS CUSTOMER_LEDGER_ID,
       ISNULL(NULLIF(DCLE.[Currency Code], N''), GLS.[LCY Code]) AS CURRENCY_ID,
       DCLE.[Customer No_] AS CUSTOMER_ID,
       CONVERT(CHAR(10), DCLE.[Posting Date], 121) AS DATE_POSTED,
       --CONVERT(CHAR(10), CLE.[Document Date], 121) AS DOCUMENT_DATE,
       CONVERT(CHAR(10), DCLE.[Initial Entry Due Date], 121) AS DATE_DUE,
       CLE.Description AS DESCRIPTION,
       DCLE.[Document No_] AS DOCUMENT_NO,
       CASE WHEN DCLE.[Document Type] = 1 THEN 'Payment'
           WHEN DCLE.[Document Type] = 2 THEN 'Invoice'
           WHEN DCLE.[Document Type] = 3 THEN 'Credit Memo'
           WHEN DCLE.[Document Type] = 4 THEN 'Finance Charge Memo'
           WHEN DCLE.[Document Type] = 5 THEN 'Reminder'
           WHEN DCLE.[Document Type] = 6 THEN 'Refund'
           ELSE NULL
       END AS DOCUMENT_TYPE,
       CASE WHEN DCLE.[Entry Type] = 1 THEN 'Initial Entry'
           WHEN DCLE.[Entry Type] = 2 THEN 'Application'
           WHEN DCLE.[Entry Type] = 3 THEN 'Unrealized Loss'
           WHEN DCLE.[Entry Type] = 4 THEN 'Unrealized Gain'
           WHEN DCLE.[Entry Type] = 5 THEN 'Realized Loss'
           WHEN DCLE.[Entry Type] = 6 THEN 'Realized Gain'
           WHEN DCLE.[Entry Type] = 7 THEN 'Payment Discount'
           WHEN DCLE.[Entry Type] = 8 THEN 'Payment Discount (VAT Excl.)'
           WHEN DCLE.[Entry Type] = 9 THEN 'Payment Discount (VAT Adjustment)'
           WHEN DCLE.[Entry Type] = 10 THEN 'Appln. Rounding'
           WHEN DCLE.[Entry Type] = 11 THEN 'Correction of Remaining Amount'
           WHEN DCLE.[Entry Type] = 12 THEN 'Payment Tolerance'
           WHEN DCLE.[Entry Type] = 13 THEN 'Payment Discount Tolerance'
           WHEN DCLE.[Entry Type] = 14 THEN 'Payment Tolerance (VAT Excl.)'
           WHEN DCLE.[Entry Type] = 15 THEN 'Payment Tolerance (VAT Adjustment)'
           WHEN DCLE.[Entry Type] = 16 THEN 'Payment Discount Tolerance (VAT Excl.)'
           WHEN DCLE.[Entry Type] = 17 THEN 'Payment Discount Tolerance (VAT Adjustment)'
           ELSE NULL
       END AS ENTRY_TYPE,
       PT.Code AS PAYMENT_TERMS,
       PT.Description AS PAYMENT_TERMS_DESCRIPTION,
       DCLE.Amount AS AMOUNT,
       DCLE.[Debit Amount] AS AMOUNT_DEBIT,
       DCLE.[Credit Amount] AS AMOUNT_CREDIT,
       DCLE.[Amount (LCY)] AS AMOUNT_BASE,
       DCLE.[Debit Amount (LCY)] AS AMOUNT_DEBIT_BASE,
       DCLE.[Credit Amount (LCY)] AS AMOUNT_CREDIT_BASE,
       IIF(CLE.[Customer Posting Group] = 'INTERNAL', 1, 0) AS IS_INTERNAL,
       CLE.[Open] AS IS_OPEN,
       CONVERT(CHAR(19), DCLE.[Posting Date], 121) AS DATE_LAST_MODIFIED
FROM dbo.[Navision Company$Detailed Cust_ Ledg_ Entry] AS DCLE
     INNER JOIN dbo.[Navision Company$Cust_ Ledger Entry] AS CLE ON DCLE.[Cust_ Ledger Entry No_] = CLE.[Entry No_]
     LEFT OUTER JOIN I ON DCLE.[Document No_] = I.No_
                          AND DCLE.[Document Type] = I.DocumentType
     LEFT OUTER JOIN PT ON I.[Payment Terms Code] = PT.Code
     OUTER APPLY dbo.[Navision Company$General Ledger Setup] AS GLS
ORDER BY DCLE.[Entry No_];