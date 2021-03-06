/****** Object:  StoredProcedure [dbo].[FFCL_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FFCL_RETRIEVE_S10] (
 @Ac_Function_CODE CHAR(3),
 @Ac_Action_CODE   CHAR(1),
 @Ac_Reason_CODE   CHAR(5)
 )
AS
 /*    
  *     PROCEDURE NAME    : FFCL_RETRIEVE_S10    
  *     DESCRIPTION       : Retrieve the Notice Idno, Barcode number, Category Code for a Function Code, Action Code, Reason Code, and Notice Idno.    
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  DECLARE @Lc_Space_TEXT        CHAR(1) = ' ',
          @Ld_High_DATE         DATE = '12/31/9999',
          @Lc_BatchOnlineI_CODE CHAR(1)='I',
          @Li_Zero_NUMB         SMALLINT = 0;

  SELECT F.Notice_ID,
         N.Category_CODE,
         @Li_Zero_NUMB AS Barcode_NUMB,
         @Li_Zero_NUMB AS TransactionEventSeq_NUMB
    FROM FFCL_Y1 F
         JOIN NREF_Y1 N
          ON N.Notice_ID = F.Notice_ID
   WHERE F.Function_CODE = @Ac_Function_CODE
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
     AND N.EndValidity_DATE = @Ld_High_DATE
     AND F.EndValidity_DATE = @Ld_High_DATE;
 END; --End of FFCL_RETRIEVE_S10        


GO
