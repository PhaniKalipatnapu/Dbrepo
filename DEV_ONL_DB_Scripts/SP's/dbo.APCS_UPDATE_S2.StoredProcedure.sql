/****** Object:  StoredProcedure [dbo].[APCS_UPDATE_S2]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCS_UPDATE_S2](
 @An_Application_IDNO         NUMERIC(15),
 @An_TransactionEventSeq_NUMB NUMERIC(19)
 )
AS
 /*                                                                                                                                                                               
 *     PROCEDURE NAME    : APCS_UPDATE_S2                                                                                                                                         
  *     DESCRIPTION       : Logically delete the valid record for an Application ID when End Validity Date is equal to High Date.                                                                                                                                                                                                           
  *     DEVELOPED BY      : IMP Team                                                                                                                                            
  *     DEVELOPED ON      : 02-MAR-2011                                                                                                                                           
  *     MODIFIED BY       :                                                                                                                                                       
  *     MODIFIED ON       :                                                                                                                                                       
  *     VERSION NO        : 1                                                                                                                                                     
 */
 BEGIN
  DECLARE @Ld_SystemDate_DATE   DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE         DATE = '12/31/9999',
          @Li_RowsAffected_NUMB INT;

  UPDATE APCS_Y1
     SET EndValidity_DATE = @Ld_Systemdate_DATE
   WHERE Application_IDNO = @An_Application_IDNO
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Li_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of APCS_UPDATE_S2


GO
