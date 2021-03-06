/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S203]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S203] (
 @An_MemberMci_IDNO   NUMERIC(10, 0),
 @An_MemberMciDp_IDNO NUMERIC(10, 0),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 /*                                                                                                                 
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S203                                                                        
  *     DESCRIPTION       : Check whether the given member is dependent or relation to the case.                                                                                        
  *     DEVELOPED BY      : IMP Team                                                                              
  *     DEVELOPED ON      : 24-AUG-2011                                                                            
  *     MODIFIED BY       :                                                                                         
  *     MODIFIED ON       :                                                                                         
  *     VERSION NO        : 1                                                                                       
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CMEM_Y1 c1
   WHERE MemberMci_IDNO = @An_MemberMci_IDNO
     AND CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
     AND (EXISTS (SELECT 1
                    FROM CMEM_Y1 c
                   WHERE c1.CASE_IDNO = c.CASE_IDNO
                     AND c.MemberMci_IDNO = @An_MemberMciDp_IDNO)
           OR EXISTS (SELECT 1
                        FROM MPAT_Y1 M
                       WHERE M.MemberMci_IDNO = @An_MemberMci_IDNO));
 END; --End of CMEM_RETRIEVE_S203                                                                                                                  


GO
