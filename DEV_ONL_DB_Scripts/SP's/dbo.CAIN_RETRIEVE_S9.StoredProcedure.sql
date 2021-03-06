/****** Object:  StoredProcedure [dbo].[CAIN_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CAIN_RETRIEVE_S9] (
 @An_TransHeader_IDNO       NUMERIC(12, 0),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ad_Transaction_DATE       DATE,
 @Ac_Function_CODE          CHAR(3),
 @Ac_Action_CODE            CHAR(1),
 @Ac_Reason_CODE            CHAR(5)
 )
AS
 /*    
  *     PROCEDURE NAME    : CAIN_RETRIEVE_S9    
  *     DESCRIPTION       : Retrieve the Notice Idno, Barcode number, Transaction sequence, and Category Code for a Transaction Header Idno, Other State Fips, Transaction Date, Function Code, Action Code, Reason Code, and Notice Idno thats common between three tables.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 01-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  DECLARE @Lc_Space_TEXT        CHAR(1) = ' ',
          @Ld_High_DATE         DATE = '12/31/9999',
          @Lc_BatchOnlineI_CODE CHAR(1) = 'I';

  SELECT F.Notice_ID,
         C.TransactionEventSeq_NUMB,
         C.Barcode_NUMB,
         N.Category_CODE
    FROM CAIN_Y1 C
         JOIN FFCL_Y1 F
          ON F.Notice_ID = C.Notice_ID
         JOIN NREF_Y1 N
          ON N.Notice_ID = F.Notice_ID
   WHERE C.TransHeader_IDNO = @An_TransHeader_IDNO
     AND C.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND C.Transaction_DATE = @Ad_Transaction_DATE
     AND F.Function_CODE = @Ac_Function_CODE
     AND F.Action_CODE = @Ac_Action_CODE
     AND F.Reason_CODE = ISNULL(@Ac_Reason_CODE, @Lc_Space_TEXT)
     AND F.Notice_ID IN (SELECT F.Notice_ID
                           FROM FFCL_Y1 F
                          WHERE F.Function_CODE = @Ac_Function_CODE
                            AND F.Action_CODE = @Ac_Action_CODE
                            AND F.Reason_CODE = ISNULL(@Ac_Reason_CODE, @Lc_Space_TEXT)
                            AND F.Notice_ID IN (SELECT N.Notice_ID
                                                  FROM NREF_Y1 N
                                                 WHERE N.BatchOnline_CODE = @Lc_BatchOnlineI_CODE)
                            AND F.EndValidity_DATE = @Ld_High_DATE)
     AND C.EndValidity_DATE = @Ld_High_DATE
     AND N.EndValidity_DATE = @Ld_High_DATE
     AND F.EndValidity_DATE = @Ld_High_DATE;
 END; --End of CAIN_RETRIEVE_S9 

GO
