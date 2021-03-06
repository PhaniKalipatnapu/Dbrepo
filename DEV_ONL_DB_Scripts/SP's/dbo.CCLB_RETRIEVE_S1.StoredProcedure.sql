/****** Object:  StoredProcedure [dbo].[CCLB_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CCLB_RETRIEVE_S1] (
 @An_TransHeader_IDNO       NUMERIC(12, 0),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ad_Transaction_DATE       DATE,
 @Ai_Record_NUMB            INT,
 @Ad_Collection_DATE        DATE OUTPUT,
 @Ad_Posting_DATE           DATE OUTPUT,
 @An_Payment_AMNT           NUMERIC(11, 2) OUTPUT,
 @Ac_PaymentSource_CODE     CHAR(1) OUTPUT,
 @Ac_PaymentMethod_CODE     CHAR(1) OUTPUT,
 @Ac_Rdfi_ID                CHAR(20) OUTPUT,
 @Ac_RdfiAcctNo_TEXT        CHAR(20) OUTPUT,
 @An_RowCount_NUMB          NUMERIC(6, 0) OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : CCLB_RETRIEVE_S1  
  *     DESCRIPTION       : Retrieve Csenet Collection Block details for a Transaction Header Idno, Transaction   Date, and Other State Fips Code.  
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 01-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  SELECT @Ad_Collection_DATE = NULL,
         @Ad_Posting_DATE = NULL,
         @An_Payment_AMNT = NULL,
         @Ac_PaymentSource_CODE = NULL,
         @Ac_PaymentMethod_CODE = NULL,
         @Ac_Rdfi_ID = NULL,
         @Ac_RdfiAcctNo_TEXT = NULL,
         @An_RowCount_NUMB = NULL;

  SELECT @Ad_Collection_DATE = X.Collection_DATE,
         @Ad_Posting_DATE = X.Posting_DATE,
         @An_Payment_AMNT = X.Payment_AMNT,
         @Ac_PaymentSource_CODE = X.PaymentSource_CODE,
         @Ac_PaymentMethod_CODE = X.PaymentMethod_CODE,
         @Ac_Rdfi_ID = X.Rdfi_ID,
         @Ac_RdfiAcctNo_TEXT = X.RdfiAcctNo_TEXT,
         @An_RowCount_NUMB = X.row_count
    FROM (SELECT CC.Collection_DATE,
                 CC.Posting_DATE,
                 CC.Payment_AMNT,
                 CC.PaymentSource_CODE,
                 CC.PaymentMethod_CODE,
                 CC.Rdfi_ID,
                 CC.RdfiAcctNo_TEXT,
                 ROW_NUMBER() OVER( ORDER BY CC.Collection_DATE) AS Record_NUMB,
                 COUNT(1) OVER() AS row_count
            FROM CCLB_Y1 CC
           WHERE CC.TransHeader_IDNO = @An_TransHeader_IDNO
             AND CC.Transaction_DATE = @Ad_Transaction_DATE
             AND CC.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE) AS X
   WHERE X.Record_NUMB = @Ai_Record_NUMB;
 END; --End of CCLB_RETRIEVE_S1

GO
