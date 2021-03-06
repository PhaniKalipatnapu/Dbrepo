/****** Object:  StoredProcedure [dbo].[DBTP_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DBTP_UPDATE_S1] (
 @Ac_TypeDebt_CODE      CHAR(2),
 @Ac_Interstate_INDC    CHAR(1),
 @Ac_SourceReceipt_CODE CHAR(2),
 @Ac_TypeWelfare_CODE   CHAR(1),
 @Ac_TypeBucket_CODE    CHAR(5)
 )
AS
 /*
 *     PROCEDURE NAME    : DBTP_UPDATE_S1
  *     DESCRIPTION       : Logically deletes the valid record for the given type debt code, welfare type, type bucket code.  
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE DBTP_Y1
     SET EndValidity_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
   WHERE TypeDebt_CODE = @Ac_TypeDebt_CODE
     AND SourceReceipt_CODE = @Ac_SourceReceipt_CODE
     AND Interstate_INDC = @Ac_Interstate_INDC
     AND TypeWelfare_CODE = @Ac_TypeWelfare_CODE
     AND TypeBucket_CODE = @Ac_TypeBucket_CODE
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End of DBTP_UPDATE_S1

GO
