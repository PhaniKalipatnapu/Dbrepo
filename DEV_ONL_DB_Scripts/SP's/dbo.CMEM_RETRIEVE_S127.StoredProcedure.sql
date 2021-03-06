/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S127]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S127](
 @An_MemberMci_IDNO NUMERIC(10, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S127
  *     DESCRIPTION       : Retrieve County Name by deriving it from last name, first name and middle initial of the Member, Members social security number, Members date of birth and retrieve indicators such as InsCoveredFlag, DentalIns, MedicalIns, VisionIns, MentalIns and PrescptIns SET to NO (N) from Member Demographics table and retrieve Unique ID Assigned to the Member, Unique ID generated for the Case, worker ID who created/modified this record and Unique Sequence Number that will be generated for any given Transaction on the Table from Case Members table for the Active (A) Member NOT equal to the given Holder whose Case is Open (O) in Case Details table and exists in Case Members table for the Member equal to the given Holder who is an Active (A) Non-Custodial Parent (A) / Putative Father (P).
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_StatusCaseOpen_CODE         CHAR(1) = 'O',
          @Lc_CaseRelationshipCp_CODE     CHAR(1) = 'C',
          @Lc_CaseRelationshipNcp_CODE    CHAR(1) = 'A',
          @Lc_CaseMembeStatusrActive_CODE CHAR(1) = 'A';

  SELECT DISTINCT CM.MemberMci_IDNO,
         D.Last_NAME,
         D.First_NAME,
         D.Middle_NAME,
         D.MemberSsn_NUMB,
         D.Birth_DATE,
         CM.Case_IDNO,
         CM.WorkerUpdate_ID,
         CM.TransactionEventSeq_NUMB
    FROM CMEM_Y1 CM
         JOIN DEMO_Y1 D
          ON D.MemberMci_IDNO = CM.MemberMci_IDNO
   WHERE CM.Case_IDNO IN (SELECT CMC.Case_IDNO
                            FROM CMEM_Y1 CMC
                                 JOIN CASE_Y1 C
                                  ON C.Case_IDNO = CMC.Case_IDNO
                           WHERE C.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                             AND CMC.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipCp_CODE)
                             AND CMC.MemberMci_IDNO = @An_MemberMci_IDNO
                             AND CMC.CaseMemberStatus_CODE = @Lc_CaseMembeStatusrActive_CODE)
     AND CM.CaseMemberStatus_CODE = @Lc_CaseMembeStatusrActive_CODE
     AND CM.MemberMci_IDNO != @An_MemberMci_IDNO;
 END -- End of CMEM_RETRIEVE_S127

GO
