/****** Object:  StoredProcedure [dbo].[USEM_RETRIEVE_S30]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_RETRIEVE_S30] (
 @An_Case_IDNO           NUMERIC(6),
 @Ac_StatusCase_CODE     CHAR(1)	OUTPUT,
 @Ac_TypeCase_CODE       CHAR(1)	OUTPUT,
 @An_County_IDNO         NUMERIC(3) OUTPUT,
 @Ac_RespondInit_CODE    CHAR(1)	OUTPUT,
 @Ac_CaseCategory_CODE   CHAR(2)	OUTPUT,
 @An_CpMci_IDNO          NUMERIC(10)OUTPUT,
 @Ac_CpLast_NAME         CHAR(20)	OUTPUT,
 @Ac_CpFirst_NAME        CHAR(16)	OUTPUT,
 @Ac_CpMiddle_NAME       CHAR(20)	OUTPUT,
 @Ac_CpSuffix_NAME       CHAR(4)	OUTPUT,
 @An_CpMemberSsn_NUMB    NUMERIC(9) OUTPUT,
 @Ad_CpBirth_DATE        DATE		OUTPUT,
 @Ac_WorkerLast_NAME     CHAR(20)	OUTPUT,
 @Ac_WorkerFirst_NAME    CHAR(16)	OUTPUT,
 @Ac_WorkerMiddle_NAME   CHAR(20)	OUTPUT,
 @Ac_WorkerSuffix_NAME   CHAR(4)	OUTPUT,
 @Ac_County_NAME         CHAR(40)	OUTPUT
 )
AS
 /*                                                                                                                           
 *     PROCEDURE NAME     : USEM_RETRIEVE_S30                                                                                                                                                         
  *     DESCRIPTION       : Retrieve Case Members Information for custodial,Non Custodial Parent and case details for a given Case.                      
  *     DEVELOPED BY      : IMP Team                                                                                        
  *     DEVELOPED ON      : 02-AUG-2011                                                                                       
  *     MODIFIED BY       :                                                                                                   
  *     MODIFIED ON       :                                                                                                   
  *     VERSION NO        : 1                                                                                                 
 */
 BEGIN
 
  DECLARE @Lc_CaseRelationshipCp_CODE        CHAR(1)	= 'C',
          @Lc_CaseMemberStatusActive_CODE    CHAR(1)	= 'A';

  SELECT @Ac_StatusCase_CODE = a.StatusCase_CODE,
         @Ac_TypeCase_CODE = a.TypeCase_CODE,
         @An_County_IDNO = a.County_IDNO,
         @Ac_RespondInit_CODE = a.RespondInit_CODE,
         @Ac_CaseCategory_CODE = a.CaseCategory_CODE,
         @An_CpMci_IDNO = e.MemberMci_IDNO,
         @Ac_CpLast_NAME = g.Last_NAME,
         @Ac_CpFirst_NAME = g.First_NAME,
         @Ac_CpMiddle_NAME = g.Middle_NAME,
         @Ac_CpSuffix_NAME = g.Suffix_NAME,
         @An_CpMemberSsn_NUMB = g.MemberSsn_NUMB,
         @Ad_CpBirth_DATE = g.Birth_DATE,
         @Ac_WorkerLast_NAME = u.Last_NAME,
         @Ac_WorkerFirst_NAME = u.First_NAME,
         @Ac_WorkerMiddle_NAME = u.Middle_NAME,
         @Ac_WorkerSuffix_NAME = u.Suffix_NAME,
         @Ac_County_NAME = c.County_NAME
    FROM CASE_Y1 a
         JOIN CMEM_Y1 e
          ON e.Case_IDNO = a.Case_IDNO
         JOIN DEMO_Y1 g
          ON e.MemberMci_IDNO = g.MemberMci_IDNO
         JOIN USEM_Y1 u
          ON a.Worker_ID = u.Worker_ID
         LEFT OUTER JOIN COPT_Y1 c
          ON a.County_IDNO = c.County_IDNO
   WHERE a.Case_IDNO = @An_Case_IDNO
     AND e.CaseRelationship_CODE = @Lc_CaseRelationshipCp_CODE
     AND e.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;
 END; --End of USEM_RETRIEVE_S30                                                                                                                          

GO
