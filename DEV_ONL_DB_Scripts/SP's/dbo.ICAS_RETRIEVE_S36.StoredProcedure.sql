/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S36]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_RETRIEVE_S36] (
 @An_Case_IDNO              NUMERIC(6, 0),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @An_RespondentMci_IDNO     NUMERIC(10, 0),
 @Ac_IVDOutOfStateCase_ID  CHAR(15) OUTPUT,
 @Ac_IVDOutOfStateTypeCase_CODE   CHAR(1) OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME     : ICAS_RETRIEVE_S36
  *     DESCRIPTION       : To Retrive out of state Case id for the Given Case and State.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 20-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
 
  SET @Ac_IVDOutOfStateCase_ID = NULL;
  SET @Ac_IVDOutOfStateTypeCase_CODE = NULL;
  
  DECLARE 
		@Lc_StatusOpen_CODE	CHAR(1) = 'O' ,
		@Ld_High_DATE		DATE	= '12/31/9999';

  SELECT TOP 1 @Ac_IVDOutOfStateCase_ID = I.IVDOutOfStateCase_ID,
               @Ac_IVDOutOfStateTypeCase_CODE = I.IVDOutOfStateTypeCase_CODE
    FROM ICAS_Y1 I
   WHERE I.Case_IDNO = @An_Case_IDNO
     AND I.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND I.RespondentMci_IDNO=@An_RespondentMci_IDNO
	 AND I.Status_CODE		= @Lc_StatusOpen_CODE
     AND EndValidity_DATE = @Ld_High_DATE
     AND ((RTRIM(LTRIM(I.IVDOutOfStateCase_ID)) <> '') OR (IVDOutOfStateTypeCase_CODE <> ''));
 END; -- End of ICAS_RETRIEVE_S36

GO
