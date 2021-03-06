/****** Object:  StoredProcedure [dbo].[APCM_RETRIEVE_S34]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APCM_RETRIEVE_S34](
 @An_Application_IDNO NUMERIC(15),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 /*
 *     PROCEDURE NAME    : APCM_RETRIEVE_S34
  *     DESCRIPTION       : Retrieve Record Count for an Application Id and Create Member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-NOV-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE                 DATE = '12/31/9999',
          @Lc_CreateMemberArchived_CODE CHAR(1) = 'A',
          @Lc_CreateMember_CODE         CHAR(1) = 'Y',
          @Lc_CreateMemberN_CODE        CHAR(1) = 'N',
          @Lc_CreateMemberU_CODE        CHAR(1) = 'U';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM APCM_Y1 AC
   WHERE AC.Application_IDNO = @An_Application_IDNO
     AND AC.CreateMemberMci_CODE NOT IN (@Lc_CreateMemberN_CODE, @Lc_CreateMemberU_CODE, @Lc_CreateMember_CODE, @Lc_CreateMemberArchived_CODE)
     AND AC.EndValidity_DATE = @Ld_High_DATE;
 END; --End of APCM_RETRIEVE_S34


GO
