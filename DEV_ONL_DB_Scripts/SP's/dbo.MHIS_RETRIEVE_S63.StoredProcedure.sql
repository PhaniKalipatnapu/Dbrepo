/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S63]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S63] (@An_Case_IDNO					NUMERIC (6),
                                    @Ac_TypeWelfare_CODE			CHAR (1),  
									@Ad_Start_DATE					DATE,
									@Ad_End_DATE					DATE,                                     
                                    @Ac_Exists_INDC					CHAR (1) OUTPUT)
AS
   BEGIN

      DECLARE
         @Lc_RelationshipCaseDp_CODE CHAR (1) = 'D',
         @Lc_StatusCaseMemberActive_CODE CHAR (1) = 'A',
         @Lc_CurrentMhis_CODE CHAR (1) = 'C';
      SET @Ac_Exists_INDC = 'N';

      SELECT TOP 1 @Ac_Exists_INDC = 'Y'
        FROM    MHIS_Y1 MH
             JOIN
                CMEM_Y1 CM
             ON MH.Case_IDNO = CM.Case_IDNO AND MH.MemberMci_IDNO = CM.MemberMci_IDNO
       WHERE     MH.Case_IDNO = @An_Case_IDNO
             AND CM.CaseRelationship_CODE = @Lc_RelationshipCaseDp_CODE
             AND CM.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE
             AND MH.TypeWelfare_CODE = @Ac_TypeWelfare_CODE
             AND MH.Start_DATE <= @Ad_Start_DATE
             AND MH.End_DATE >= @Ad_End_DATE;
   END

GO
