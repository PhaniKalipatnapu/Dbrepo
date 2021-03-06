/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S35]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_RETRIEVE_S35] (
 @An_Case_IDNO                    NUMERIC(6, 0),
 @Ac_IVDOutOfStateFips_CODE       CHAR(2),
 @Ac_Reason_CODE                  CHAR(5),
 @An_RespondentMci_IDNO           NUMERIC(10, 0),
 @Ac_IVDOutOfStateOfficeFips_CODE CHAR(2) OUTPUT,
 @Ac_IVDOutOfStateCountyFips_CODE CHAR(3) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : ICAS_RETRIEVE_S35
  *     DESCRIPTION       : To Get IVDOutOfStateOfficeFips_CODE and IVDOutOfStateCountyFips_CODE for Notice Generation.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-DEC-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ac_IVDOutOfStateOfficeFips_CODE = NULL;
  SET @Ac_IVDOutOfStateCountyFips_CODE = NULL;

  DECLARE @Lc_StatusOpen_CODE CHAR(1) = 'O',
          @Ld_High_DATE       DATE = '12/31/9999';

  SELECT TOP 1 @Ac_IVDOutOfStateOfficeFips_CODE = ISNULL(i.IVDOutOfStateOfficeFips_CODE, '00'),
               @Ac_IVDOutOfStateCountyFips_CODE = ISNULL(i.IVDOutOfStateCountyFips_CODE, '000')
    FROM ICAS_Y1 i
   WHERE i.Case_IDNO = @An_Case_IDNO
     AND i.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
     AND i.Status_CODE = @Lc_StatusOpen_CODE
     AND i.Reason_CODE = ISNULL(@Ac_Reason_CODE, i.Reason_CODE)
     AND i.RespondentMCI_IDNO = @An_RespondentMci_IDNO
     AND i.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of ICAS_RETRIEVE_S35

GO
