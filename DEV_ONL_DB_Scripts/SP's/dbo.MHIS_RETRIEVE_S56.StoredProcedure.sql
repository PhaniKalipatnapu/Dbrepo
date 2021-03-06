/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S56]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                                                                                           
CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S56] (
 @An_Case_IDNO      NUMERIC(6, 0),
 @An_MemberMci_IDNO NUMERIC(10, 0)
 )
AS
 /*                                                                                                    
  *     PROCEDURE NAME    : MHIS_RETRIEVE_S56                                                           
  *     DESCRIPTION       : This Procedures populates data for  Member Status History pop-up view displays
                            the member status history when a change is made to the status on MHIS.  Details
                            displayed include the beginning and end dates for the program type, the CP name,
                            IV-A Referral No and the reason code for the change.                                                                         
  *     DEVELOPED BY      : IMP Team                                                                 
  *     DEVELOPED ON      : 12/10/2011                                                        
  *     MODIFIED BY       :                                                                            
  *     MODIFIED ON       :                                                                            
  *     VERSION NO        : 1                                                                          
  */
 BEGIN
  WITH Mhis_CTE
       AS (SELECT M.Case_IDNO,
                  M.MemberMci_IDNO,
                  M.Start_DATE,
                  M.End_DATE,
                  M.TypeWelfare_CODE,
                  M.CaseWelfare_IDNO,
                  M.Reason_CODE,
                  M.BeginValidity_DATE,
                  M.EventGlobalBeginSeq_NUMB
             FROM MHIS_Y1 M
            WHERE M.MemberMci_IDNO = @An_MemberMci_IDNO
              AND M.Case_IDNO = @An_Case_IDNO)
  SELECT M.Case_IDNO,
         M.MemberMci_IDNO,
         M.Start_DATE,
         M.End_DATE,
         M.TypeWelfare_CODE,
         D.Last_NAME,
         D.First_NAME,
         D.Middle_NAME,
         D.Suffix_NAME,
         M.CaseWelfare_IDNO,
         M.Case_IDNO,
         M.Reason_CODE,
         G.Worker_ID,
         UN.DescriptionNote_TEXT,
         M.BeginValidity_DATE
    FROM Mhis_CTE M
         JOIN GLEV_Y1 G
          ON G.EventGlobalSeq_NUMB = M.EventGlobalBeginSeq_NUMB
         JOIN DEMO_Y1 D
          ON D.MemberMci_IDNO = M.MemberMci_IDNO
         LEFT OUTER JOIN UNOT_Y1 Un
          ON UN.EventGlobalSeq_NUMB = G.EventGlobalSeq_NUMB
   ORDER BY M.Start_DATE DESC,
            M.End_DATE   DESC,
            M.Case_IDNO  DESC;
            
 END; --End Of Procedure MHIS_RETRIEVE_S56 


GO
