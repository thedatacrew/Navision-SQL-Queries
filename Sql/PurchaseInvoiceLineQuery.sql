WITH
PINV AS
   ( SELECT PIL.[Document No_] + '-I-' + CAST(PIL.[Line No_] AS VARCHAR(16)) AS PURCHASE_INVOICE_ITEM_ID,
            NULLIF(PIH.[Purchaser Code], '') AS BUYER_ID,
            ISNULL(NULLIF(PIH.[Currency Code], N''), GLS.[LCY Code]) AS CURRENCY_ID,
            PIL.No_ AS ITEM_ID,
            PIL.[Location Code] AS LOCATION_ID,
            PIH.[Pay-to Vendor No_] AS BUY_FROM_SUPPLIER_ID,
            PIL.[Buy-from Vendor No_] AS PAY_TO_SUPPLIER_ID,
            NULLIF(LTRIM(RTRIM(I.[Vendor Item No_])), '') AS SUPPLIER_ITEM_ID,
            PIL.[Document No_] AS INVOICE_NUMBER,
            NULLIF(LTRIM(RTRIM(PIH.[Order No_])), '') AS PURCHASE_ORDER_NUMBER,
            PIL.[Line No_] AS LINE_NUMBER,
            NULL AS BUYER_NAME,
            VBF.Name AS BUY_FROM_SUPPLIER_NAME,
            VPT.Name AS PAY_TO_SUPPLIER_NAME,
            NULL AS DELIVERY_NUMBER,
            'Purchase Invoice' AS DOCUMENT_TYPE,
            CONVERT(CHAR(10), PIH.[Document Date], 121) AS INVOICE_DATE,
            NULL AS INVOICE_STATUS,
            NULL AS LINE_STATUS,
            PIL.Description AS DESCRIPTION,
            -- PIL.[Item Category Code] AS ITEM_CATEGORY_CODE
            PIL.Quantity AS QUANTITY,
            NULLIF(LTRIM(RTRIM(PIL.[Unit of Measure])), '') AS UNIT_OF_MEASURE,
            PIL.[VAT Identifier] AS TAX_CODE,
            PIL.[VAT _] AS TAX_RATE,
            CONVERT(CHAR(10), PIH.[Due Date], 121) AS DUE_DATE,
            CONVERT(CHAR(10), PIH.[Due Date], 121) AS DATE_PAYMENT_PLANNED,
            CONVERT(CHAR(10), PIL.[Expected Receipt Date], 121) AS RECEIPT_DATE,
            PIL.[Line Discount _] AS LINE_DISCOUNT_RATE,
            PIH.[Payment Discount _] AS INVOICE_DISCOUNT_RATE,
            NULL AS TOTAL_DISCOUNT_RATE,
            PIL.[Unit Cost] AS UNIT_COST,
            PIL.[Line Discount Amount] AS DISCOUNT_AMOUNT,
            PIL.Amount AS NET_AMOUNT,
            PIL.[Amount Including VAT] - PIL.Amount AS TAX_AMOUNT,
            PIL.[Amount Including VAT] AS GROSS_AMOUNT,
            PIL.[Unit Cost (LCY)] AS BASE_UNIT_COST,
            CASE WHEN PIH.[Currency Factor] = 0 THEN PIL.[Line Discount Amount]
                ELSE ( 1 / PIH.[Currency Factor] ) * PIL.[Line Discount Amount]
            END AS BASE_DISCOUNT_AMOUNT,
            CASE WHEN PIH.[Currency Factor] = 0 THEN PIL.Amount ELSE ( 1 / PIH.[Currency Factor] ) * PIL.Amount END AS BASE_NET_AMOUNT,
            CASE WHEN PIH.[Currency Factor] = 0 THEN PIL.[Amount Including VAT] - PIL.Amount
                ELSE ( 1 / PIH.[Currency Factor] ) * ( PIL.[Amount Including VAT] - PIL.Amount )
            END AS BASE_TAX_AMOUNT,
            CASE WHEN PIH.[Currency Factor] = 0 THEN PIL.[Amount Including VAT]
                ELSE ( 1 / PIH.[Currency Factor] ) * PIL.[Amount Including VAT]
            END AS BASE_GROSS_AMOUNT,
            PIH.[Payment Terms Code] AS PAYMENT_TERMS,
            PT.Description AS PAYMENT_TERMS_DESCRIPTION,
            NULL AS LOADED_BY,
            U.[User Name] AS CREATED_BY,
            U.[User Name] AS MODIFIED_BY,
            CONVERT(CHAR(19), GETDATE(), 121) AS DATE_LOADED,
            CONVERT(CHAR(19), PIL.[Posting Date], 121) AS DATE_CREATED,
            CONVERT(CHAR(19), PIL.[Posting Date], 121) AS DATE_MODIFIED
     FROM dbo.[Navision Company$Purch_ Inv_ Header] AS PIH
          LEFT OUTER JOIN dbo.[Navision Company$Purch_ Inv_ Line] AS PIL ON PIH.No_ = PIL.[Document No_]
          LEFT OUTER JOIN dbo.[Navision Company$Item] AS I ON PIL.No_ = I.No_
          LEFT OUTER JOIN dbo.[Navision Company$Vendor] AS VBF ON PIH.[Buy-from Vendor No_] = VBF.No_
          LEFT OUTER JOIN dbo.[Navision Company$Vendor] AS VPT ON PIH.[Pay-to Vendor No_] = VPT.No_
          LEFT OUTER JOIN dbo.[User] AS U ON PIH.[User ID] = U.[User Name]
          LEFT OUTER JOIN dbo.[Navision Company$Payment Terms] AS PT ON PIH.[Payment Terms Code] = PT.Code
          OUTER APPLY dbo.[Navision Company$General Ledger Setup] AS GLS
     WHERE PIL.Amount <> 0
     UNION ALL
     SELECT PIL.[Document No_] + '-R-' + CAST(PIL.[Line No_] AS VARCHAR(16)) AS PURCHASE_INVOICE_ITEM_ID,
            NULLIF(PIH.[Purchaser Code], '') AS BUYER_ID,
            ISNULL(NULLIF(PIH.[Currency Code], N''), GLS.[LCY Code]) AS CURRENCY_ID,
            PIH.[Currency Factor] AS CURRENCY_RATE,
            PIL.No_ AS ITEM_ID,
            PIL.[Location Code] AS LOCATION_ID,
            PIH.[Pay-to Vendor No_] AS BUY_FROM_SUPPLIER_ID,
            PIL.[Buy-from Vendor No_] AS PAY_TO_SUPPLIER_ID,
            NULLIF(LTRIM(RTRIM(I.[Vendor Item No_])), '') AS SUPPLIER_ITEM_ID,
            PIL.[Document No_] AS INVOICE_NUMBER,
            NULLIF(LTRIM(RTRIM(PIH.[Return Order No_])), '') AS PURCHASE_ORDER_NUMBER,
            PIL.[Line No_] AS LINE_NUMBER,
            NULL AS BUYER_NAME,
            VBF.Name AS BUY_FROM_SUPPLIER_NAME,
            VPT.Name AS PAY_TO_SUPPLIER_NAME,
            NULL AS DELIVERY_NUMBER,
            'Purchase Invoice Return' AS DOCUMENT_TYPE,
            CONVERT(CHAR(10), PIH.[Document Date], 121) AS INVOICE_DATE,
            NULL AS INVOICE_STATUS,
            NULL AS LINE_STATUS,
            PIL.Description AS DESCRIPTION,
            -- PIL.[Item Category Code] AS ITEM_CATEGORY_CODE
            CAST(PIL.Quantity AS DECIMAL(38, 4)) AS QUANTITY,
            NULLIF(LTRIM(RTRIM(PIL.[Unit of Measure])), '') AS UNIT_OF_MEASURE,
            PIL.[VAT Identifier] AS TAX_CODE,
            PIL.[VAT _] AS TAX_RATE,
            CONVERT(CHAR(10), PIH.[Due Date], 121) AS DUE_DATE,
            CONVERT(CHAR(10), PIH.[Due Date], 121) AS DATE_PAYMENT_PLANNED,
            CONVERT(CHAR(10), PIL.[Expected Receipt Date], 121) AS RECEIPT_DATE,
            PIL.[Line Discount _] AS LINE_DISCOUNT_RATE,
            PIH.[Payment Discount _] AS INVOICE_DISCOUNT_RATE,
            NULL AS TOTAL_DISCOUNT_RATE,
            PIL.[Unit Cost] AS UNIT_COST,
            CASE WHEN SIGN(PIL.[Line Discount Amount]) IN ( 1, 0 ) THEN PIL.[Line Discount Amount]
                ELSE -ABS(PIL.[Line Discount Amount])
            END AS DISCOUNT_AMOUNT,
            CASE WHEN SIGN(PIL.Amount) IN ( 1, 0 ) THEN PIL.Amount ELSE -ABS(PIL.Amount) END AS NET_AMOUNT,
            CASE WHEN SIGN(PIL.[Amount Including VAT] - PIL.Amount) IN ( 1, 0 ) THEN PIL.[Amount Including VAT] - PIL.Amount
                ELSE -ABS(PIL.[Amount Including VAT] - PIL.Amount)
            END AS TAX_AMOUNT,
            CASE WHEN SIGN(PIL.[Amount Including VAT]) IN ( 1, 0 ) THEN PIL.[Amount Including VAT]
                ELSE -ABS(PIL.[Amount Including VAT])
            END AS GROSS_AMOUNT,
            PIL.[Unit Cost (LCY)] AS BASE_UNIT_COST,
            CASE WHEN PIH.[Currency Factor] = 0 THEN CASE WHEN SIGN(PIL.[Line Discount Amount]) IN ( 1, 0 ) THEN PIL.[Line Discount Amount]
                                                         ELSE -ABS(PIL.[Line Discount Amount])
                                                     END
                ELSE ( 1 / PIH.[Currency Factor] ) * CASE WHEN SIGN(PIL.[Line Discount Amount]) IN ( 1, 0 ) THEN PIL.[Line Discount Amount]
                                                         ELSE -ABS(PIL.[Line Discount Amount])
                                                     END
            END AS BASE_DISCOUNT_AMOUNT,
            CASE WHEN PIH.[Currency Factor] = 0 THEN CASE WHEN SIGN(PIL.Amount) IN ( 1, 0 ) THEN PIL.Amount ELSE -ABS(PIL.Amount) END
                ELSE ( 1 / PIH.[Currency Factor] ) * CASE WHEN SIGN(PIL.Amount) IN ( 1, 0 ) THEN PIL.Amount ELSE -ABS(PIL.Amount) END
            END AS BASE_NET_AMOUNT,
            CASE WHEN PIH.[Currency Factor] = 0 THEN CASE WHEN SIGN(PIL.[Amount Including VAT] - PIL.Amount) IN ( 1, 0 ) THEN PIL.[Amount Including VAT] - PIL.Amount
                                                         ELSE -ABS(PIL.[Amount Including VAT] - PIL.Amount)
                                                     END
                ELSE ( 1 / PIH.[Currency Factor] ) * CASE WHEN SIGN(PIL.[Amount Including VAT] - PIL.Amount) IN ( 1, 0 ) THEN PIL.[Amount Including VAT] - PIL.Amount
                                                         ELSE -ABS(PIL.[Amount Including VAT] - PIL.Amount)
                                                     END
            END AS BASE_TAX_AMOUNT,
            CASE WHEN PIH.[Currency Factor] = 0 THEN CASE WHEN SIGN(PIL.[Amount Including VAT]) IN ( 1, 0 ) THEN PIL.[Amount Including VAT]
                                                         ELSE -ABS(PIL.[Amount Including VAT])
                                                     END
                ELSE ( 1 / PIH.[Currency Factor] ) * CASE WHEN SIGN(PIL.[Amount Including VAT]) IN ( 1, 0 ) THEN PIL.[Amount Including VAT]
                                                         ELSE -ABS(PIL.[Amount Including VAT])
                                                     END
            END AS BASE_GROSS_AMOUNT,
            PIH.[Payment Terms Code] AS PAYMENT_TERMS,
            PT.Description AS PAYMENT_TERMS_DESCRIPTION,
            NULL AS LOADED_BY,
            U.[User Name] AS CREATED_BY,
            U.[User Name] AS MODIFIED_BY,
            CONVERT(CHAR(19), GETDATE(), 121) AS DATE_LOADED,
            CONVERT(CHAR(19), PIL.[Posting Date], 121) AS DATE_CREATED,
            CONVERT(CHAR(19), PIL.[Posting Date], 121) AS DATE_MODIFIED
     FROM dbo.[Navision Company$Purch_ Cr_ Memo Hdr_] AS PIH
          LEFT OUTER JOIN dbo.[Navision Company$Purch_ Cr_ Memo Line] AS PIL ON PIH.No_ = PIL.[Document No_]
          LEFT OUTER JOIN dbo.[Navision Company$Item] AS I ON PIL.No_ = I.No_
          LEFT OUTER JOIN dbo.[Navision Company$Vendor] AS VBF ON PIH.[Buy-from Vendor No_] = VBF.No_
          LEFT OUTER JOIN dbo.[Navision Company$Vendor] AS VPT ON PIH.[Pay-to Vendor No_] = VPT.No_
          LEFT OUTER JOIN dbo.[User] AS U ON PIH.[User ID] = U.[User Name]
          LEFT OUTER JOIN dbo.[Navision Company$Payment Terms] AS PT ON PIH.[Payment Terms Code] = PT.Code
          OUTER APPLY dbo.[Navision Company$General Ledger Setup] AS GLS )
SELECT PINV.PURCHASE_INVOICE_ITEM_ID,
       PINV.BUYER_ID,
       PINV.CURRENCY_ID,
       PINV.LEGAL_ENTITY_ID,
       PINV.ITEM_ID,
       PINV.LOCATION_ID,
       PINV.BUY_FROM_SUPPLIER_ID,
       PINV.PAY_TO_SUPPLIER_ID,
       PINV.SUPPLIER_ITEM_ID,
       PINV.INVOICE_NUMBER,
       PINV.PURCHASE_ORDER_NUMBER,
       PINV.LINE_NUMBER,
       PINV.BUYER_NAME,
       PINV.BUY_FROM_SUPPLIER_NAME,
       PINV.PAY_TO_SUPPLIER_NAME,
       PINV.DELIVERY_NUMBER,
       PINV.DOCUMENT_TYPE,
       PINV.INVOICE_DATE,
       PINV.INVOICE_STATUS,
       PINV.LINE_STATUS,
       PINV.DESCRIPTION,
       PINV.QUANTITY,
       PINV.UNIT_OF_MEASURE,
       PINV.TAX_CODE,
       CAST(PINV.TAX_RATE AS DECIMAL(38, 4)) AS TAX_RATE,
       PINV.DUE_DATE,
       PINV.DATE_PAYMENT_PLANNED,
       PINV.RECEIPT_DATE,
       CAST(PINV.LINE_DISCOUNT_RATE AS DECIMAL(38, 4)) AS LINE_DISCOUNT_RATE,
       CAST(PINV.INVOICE_DISCOUNT_RATE AS DECIMAL(38, 4)) AS INVOICE_DISCOUNT_RATE,
       CAST(PINV.TOTAL_DISCOUNT_RATE AS DECIMAL(38, 4)) AS TOTAL_DISCOUNT_RATE,
       CAST(PINV.UNIT_COST AS DECIMAL(38, 4)) AS UNIT_COST,
       CAST(PINV.DISCOUNT_AMOUNT AS DECIMAL(38, 4)) AS DISCOUNT_AMOUNT,
       CAST(PINV.NET_AMOUNT AS DECIMAL(38, 4)) AS NET_AMOUNT,
       CAST(PINV.TAX_AMOUNT AS DECIMAL(38, 4)) AS TAX_AMOUNT,
       CAST(PINV.GROSS_AMOUNT AS DECIMAL(38, 4)) AS GROSS_AMOUNT,
       CAST(PINV.BASE_UNIT_COST AS DECIMAL(38, 4)) AS BASE_UNIT_COST,
       CAST(PINV.BASE_DISCOUNT_AMOUNT AS DECIMAL(38, 4)) AS BASE_DISCOUNT_AMOUNT,
       CAST(PINV.BASE_NET_AMOUNT AS DECIMAL(38, 4)) AS BASE_NET_AMOUNT,
       CAST(PINV.BASE_TAX_AMOUNT AS DECIMAL(38, 4)) AS BASE_TAX_AMOUNT,
       CAST(PINV.BASE_GROSS_AMOUNT AS DECIMAL(38, 4)) AS BASE_GROSS_AMOUNT,
       PINV.PAYMENT_TERMS,
       PINV.PAYMENT_TERMS_DESCRIPTION,
       PINV.LOADED_BY,
       PINV.CREATED_BY,
       PINV.MODIFIED_BY,
       PINV.DATE_LOADED,
       PINV.DATE_CREATED,
       PINV.DATE_MODIFIED
FROM PINV;

