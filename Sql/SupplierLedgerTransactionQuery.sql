;WITH
I   AS
( SELECT PIH.No_,
         PIH.[Payment Terms Code],
         2 AS DocumentType
  FROM dbo.[Navision Company$Purch_ Inv_ Header] AS PIH
  UNION
  SELECT PCMH.No_,
         PCMH.[Payment Terms Code],
         3 AS DocumentType
  FROM dbo.[Navision Company$Purch_ Cr_ Memo Hdr_] AS PCMH ),
PT  AS
( SELECT PT.Code, PT.Description FROM dbo.[Navision Company$Payment Terms] AS PT )
SELECT DVLE.[Entry No_] AS SUPPLIER_LEDGER_TRASANCTION_ID,
       ISNULL(NULLIF(DVLE.[Currency Code], N''), GLS.[LCY Code]) AS CURRENCY_ID,
       DVLE.[Vendor No_] AS SUPPLIER_ID,
       DVLE.[Vendor Ledger Entry No_] AS SUPPLIER_LEDGER_ID,
       CONVERT(CHAR(10), DVLE.[Posting Date], 121) AS DATE_POSTED,
       CONVERT(CHAR(10), DVLE.[Initial Entry Due Date], 121) AS DATE_DUE,
       VLE.Description AS DESCRIPTION,
       DVLE.[Document No_] AS DOCUMENT_NO,
       CASE WHEN DVLE.[Document Type] = 1 THEN 'Payment'
           WHEN DVLE.[Document Type] = 2 THEN 'Invoice'
           WHEN DVLE.[Document Type] = 3 THEN 'Credit Memo'
           WHEN DVLE.[Document Type] = 4 THEN 'Finance Charge Memo'
           WHEN DVLE.[Document Type] = 5 THEN 'Reminder'
           WHEN DVLE.[Document Type] = 6 THEN 'Refund'
           ELSE NULL
       END AS DOCUMENT_TYPE,
       CASE WHEN DVLE.[Entry Type] = 1 THEN 'Initial Entry'
           WHEN DVLE.[Entry Type] = 2 THEN 'Application'
           WHEN DVLE.[Entry Type] = 3 THEN 'Unrealized Loss'
           WHEN DVLE.[Entry Type] = 4 THEN 'Unrealized Gain'
           WHEN DVLE.[Entry Type] = 5 THEN 'Realized Loss'
           WHEN DVLE.[Entry Type] = 6 THEN 'Realized Gain'
           WHEN DVLE.[Entry Type] = 7 THEN 'Payment Discount'
           WHEN DVLE.[Entry Type] = 8 THEN 'Payment Discount (VAT Excl.)'
           WHEN DVLE.[Entry Type] = 9 THEN 'Payment Discount (VAT Adjustment)'
           WHEN DVLE.[Entry Type] = 10 THEN 'Appln. Rounding'
           WHEN DVLE.[Entry Type] = 11 THEN 'Correction of Remaining Amount'
           WHEN DVLE.[Entry Type] = 12 THEN 'Payment Tolerance'
           WHEN DVLE.[Entry Type] = 13 THEN 'Payment Discount Tolerance'
           WHEN DVLE.[Entry Type] = 14 THEN 'Payment Tolerance (VAT Excl.)'
           WHEN DVLE.[Entry Type] = 15 THEN 'Payment Tolerance (VAT Adjustment)'
           WHEN DVLE.[Entry Type] = 16 THEN 'Payment Discount Tolerance (VAT Excl.)'
           WHEN DVLE.[Entry Type] = 17 THEN 'Payment Discount Tolerance (VAT Adjustment)'
           ELSE NULL
       END AS ENTRY_TYPE,
       PT.Code AS PAYMENT_TERMS,
       PT.Description AS PAYMENT_TERMS_DESCRIPTION,
       DVLE.Amount AS AMOUNT,
       DVLE.[Debit Amount] AS AMOUNT_DEBIT,
       DVLE.[Credit Amount] AS AMOUNT_CREDIT,
       DVLE.[Amount (LCY)] AS AMOUNT_BASE,
       DVLE.[Debit Amount (LCY)] AS AMOUNT_DEBIT_BASE,
       DVLE.[Credit Amount (LCY)] AS AMOUNT_CREDIT_BASE,
       CASE WHEN VLE.[Vendor Posting Group] = 'INTERNAL' THEN CAST(1 AS BIT)ELSE CAST(0 AS BIT)END AS IS_INTERNAL,
       VLE.[Open] AS IS_OPEN,
       NULL AS LOADED_BY,
       U.[User Name] AS CREATED_BY,
       U.[User Name] AS MODIFIED_BY,
       CONVERT(CHAR(19), GETDATE(), 121) AS DATE_LOADED,
       CONVERT(CHAR(19), DVLE.[Posting Date], 121) AS DATE_CREATED,
       CONVERT(CHAR(19), DVLE.[Posting Date], 121) AS DATE_MODIFIED
FROM dbo.[Navision Company$Detailed Vendor Ledg_ Entry] AS DVLE
     INNER JOIN dbo.[Navision Company$Vendor Ledger Entry] AS VLE ON DVLE.[Vendor Ledger Entry No_] = VLE.[Entry No_]
     LEFT OUTER JOIN dbo.[User] AS U ON VLE.[User ID] = U.[User Name]
     LEFT OUTER JOIN I ON DVLE.[Document No_] = I.No_
                          AND DVLE.[Document Type] = I.DocumentType
     LEFT OUTER JOIN PT ON I.[Payment Terms Code] = PT.Code
     OUTER APPLY dbo.[Navision Company$General Ledger Setup] AS GLS
ORDER BY DVLE.[Entry No_];
