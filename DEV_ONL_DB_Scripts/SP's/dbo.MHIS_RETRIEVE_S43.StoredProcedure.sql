/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S43]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S43](
 @An_Case_IDNO      NUMERIC(6, 0),
 @An_MemberMci_IDNO NUMERIC(10, 0)
 )
AS
 /*                                                                                                                                                                                                                                                                                                                                                                                                
  *     PROCEDURE NAME    : MHIS_RETRIEVE_S43                                                                                                                                                                                                                                                                                                                                                       
  *     DESCRIPTION       : Retrieves the Case Id, Member Id, The date from which the given member status is valid, The date up to which the given member status is valid, Welfare Case Id, The Program Type, Welfare Identification of the Member, Indicator to check Member is Case Head or no, and Reason for the change in the Member's status (program type) for the given Case Id, Member Id.
  *     DEVELOPED BY      : IMP Team                                                                                                                                                                                                                                                                                                                                                             
  *     DEVELOPED ON      : 02-NOV-2011                                                                                                                                                                                                                                                                                                                                                            
  *     MODIFIED BY       :                                                                                                                                                                                                                                                                                                                                                                        
  *     MODIFIED ON       :                                                                                                                                                                                                                                                                                                                                                                        
  *     VERSION NO        : 1                                                                                                                                                                                                                                                                                                                                                                      
 */
 BEGIN
  SELECT M.MemberMci_IDNO,
         M.Case_IDNO,
         M.Start_DATE,
         M.End_DATE,
         M.TypeWelfare_CODE,
         M.CaseWelfare_IDNO,
         M.WelfareMemberMci_IDNO,
         M.CaseHead_INDC,
         M.Reason_CODE
    FROM MHIS_Y1 M
   WHERE M.Case_IDNO = @An_Case_IDNO
     AND M.MemberMci_IDNO = @An_MemberMci_IDNO
      ORDER BY End_DATE DESC;
 END; --End of MHIS_RETRIEVE_S43


GO
