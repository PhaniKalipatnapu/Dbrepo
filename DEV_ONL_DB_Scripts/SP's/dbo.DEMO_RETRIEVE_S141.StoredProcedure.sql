/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S141]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S141] (
 @An_Case_IDNO NUMERIC(6, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : DEMO_RETRIEVE_S141
  *     DESCRIPTION       : 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 23-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_CaseRelationShipCp_CODE	CHAR(1) = 'C',
			@Lc_CaseRelationShipNcp_CODE	CHAR(1) = 'A',
			@Lc_CaseRelationShipDep_CODE	CHAR(1) = 'D',
			@Lc_CaseMemberStatusActive_CODE    CHAR(1) = 'A';

	SELECT A.Last_NAME,
            A.First_NAME,
            A.Middle_NAME,
            A.MemberSsn_NUMB,
            A.Birth_DATE,
            A.FamilyViolence_INDC,
            A.CaseRelationShip_CODE, 
            A.RowCount_NUMB,
            A.Rownum_NUMB,
			M.BornOfMarriage_CODE
	FROM (SELECT D.MemberMci_IDNO,
				D.Last_NAME,
                D.First_NAME,
                D.Middle_NAME,
                D.MemberSsn_NUMB,
                D.Birth_DATE,
                C.FamilyViolence_INDC,
                C.CaseRelationShip_CODE,                        
                COUNT (1) OVER () AS RowCount_NUMB,
                ROW_NUMBER () OVER ( ORDER BY C.MemberMci_IDNO ) AS Rownum_NUMB
			FROM CMEM_Y1 C, DEMO_Y1 D
			WHERE C.MemberMci_IDNO = D.MemberMci_IDNO                 
			  AND C.Case_IDNO = @An_Case_IDNO
			  AND C.CaseRelationShip_CODE IN (@Lc_CaseRelationShipCp_CODE, @Lc_CaseRelationShipNcp_CODE, @Lc_CaseRelationShipDep_CODE)
			  AND C.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE 
			  ) A LEFT OUTER JOIN   MPAT_Y1 M
	ON( A.MemberMci_IDNO = M.MemberMci_IDNO)
		
					
 END; --End Of DEMO_RETRIEVE_S141

GO
