/****** Object:  StoredProcedure [dbo].[FIPS_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FIPS_UPDATE_S1] (
 @Ac_Fips_CODE                CHAR(7),
 @Ac_TypeAddress_CODE         CHAR(3),
 @Ac_SubTypeAddress_CODE      CHAR(3),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : FIPS_UPDATE_S1
  *     DESCRIPTION       : EndValidating the record for a given Fips with Specified addresses
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 08-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
          @Ld_Current_DATE      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE FIPS_Y1
     SET EndValidity_DATE = @Ld_Current_DATE
   WHERE Fips_CODE = @Ac_Fips_CODE
     AND TypeAddress_CODE = @Ac_TypeAddress_CODE
     AND SubTypeAddress_CODE = @Ac_SubTypeAddress_CODE
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --END OF  FIPS_UPDATE_S1   


GO
