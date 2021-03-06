/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S130]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S130](
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ac_Exists_INDC    CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S130
  *     DESCRIPTION       : Retrieve the Interstate Indicator count of records from Case Members table for the Active (A) Dependant (D) Member whose Case is Open (O) in Case Details table with Respond Init Code equal to Initiation (I) / Responding (R).
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_StatusCaseOpen_CODE         CHAR(1) = 'O',
          @Lc_RespondInitInitiate_CODE    CHAR(1) = 'I',
          @Lc_RespondInitC_CODE           CHAR(1) = 'C',
          @Lc_RespondInitT_CODE           CHAR(1) = 'T',
          @Lc_RespondInitS_CODE           CHAR(1) = 'S',
          @Lc_RespondInitY_CODE           CHAR(1) = 'Y',
          @Lc_RespondInitResponding_CODE  CHAR(1) = 'R',
          @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A',
          @Lc_Yes_INDC                    CHAR(1) = 'Y',
          @Lc_No_INDC                     CHAR(1) = 'N';

  SET @Ac_Exists_INDC = @Lc_No_INDC;

  SELECT TOP 1 @Ac_Exists_INDC = @Lc_Yes_INDC
    FROM CASE_Y1 C
         JOIN CMEM_Y1 CM
          ON CM.Case_IDNO = C.Case_IDNO
   WHERE CM.MemberMci_IDNO = @An_MemberMci_IDNO
     AND C.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
     AND C.RespondInit_CODE IN (@Lc_RespondInitInitiate_CODE, @Lc_RespondInitC_CODE, @Lc_RespondInitT_CODE, @Lc_RespondInitResponding_CODE,@Lc_RespondInitS_CODE, @Lc_RespondInitY_CODE)
     AND CM.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;
 END -- End of CMEM_RETRIEVE_S130

GO
