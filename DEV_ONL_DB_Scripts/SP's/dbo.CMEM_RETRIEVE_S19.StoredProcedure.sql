/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S19]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S19] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ai_Count_QNTY     INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S19
  *     DESCRIPTION       : Retrieve the count of records from Case Members table for the Active Member whose Case does exist in Major Activity Diary table with Code with in the system for the Major Activity equal to Immediate Income Withholding (IMIW) / Unemployment and Disability (UEDB) / Qualified/Eligible Domestic Relations Order (QDRO) and Status of the Remedy equal to START (STRT).
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 06-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A',
          @Lc_ActivityMajorImiw_CODE      CHAR(4) = 'IMIW',
          @Lc_StatusStart_CODE            CHAR(4) = 'STRT';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM DMJR_Y1 D
         JOIN CMEM_Y1 M
          ON M.Case_IDNO = D.Case_IDNO
   WHERE M.MemberMci_IDNO = @An_MemberMci_IDNO
     AND M.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
     AND D.ActivityMajor_CODE IN (@Lc_ActivityMajorImiw_CODE)
     AND D.Status_CODE = @Lc_StatusStart_CODE;
 END; -- END OF CMEM_RETRIEVE_S19


GO
