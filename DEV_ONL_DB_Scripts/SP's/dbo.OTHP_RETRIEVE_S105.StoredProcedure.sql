/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S105]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S105] (
 @Ac_TypeOthp_CODE CHAR(1),
 @An_Case_IDNO     NUMERIC(6, 0),
 @Ai_RowFrom_NUMB  INT = 1,
 @Ai_RowTo_NUMB    INT = 10
 )
AS
 /*
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S105
  *     DESCRIPTION       : Retrieve the Other Party details for a Member Id, Income type and Status Code is Yes.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 16-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_CaseRelationshipCp_CODE        CHAR(1) = 'C',
          @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseMemberStatusActive_CODE    CHAR(1) = 'A',
          @Lc_TypeOthpMilitary_CODE			 CHAR(1) = 'M',
          @Lc_Yes_INDC                       CHAR(1) = 'Y',
          @Ld_High_DATE                      DATE = '12/31/9999';
  DECLARE @Ld_Today_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT x.OtherParty_IDNO,
         x.OtherParty_NAME,
         x.Line1_ADDR,
         x.Line2_ADDR,
         x.City_ADDR,
         x.Zip_ADDR,
         x.State_ADDR,
         x.Fein_IDNO,
         x.CaseRelationship_CODE,
         x.MemberMci_IDNO,
         x.RowCount_NUMB
    FROM (SELECT o.Fein_IDNO,
                 o.OtherParty_IDNO,
                 o.OtherParty_NAME,
                 o.Line1_ADDR,
                 o.Line2_ADDR,
                 o.City_ADDR,
                 o.State_ADDR,
                 o.Zip_ADDR,
                 e.MemberMci_IDNO,
                 d.CaseRelationship_CODE,
                 ROW_NUMBER() OVER ( ORDER BY o.OtherParty_IDNO ) AS rn,
                 COUNT(1) OVER() AS RowCount_NUMB
            FROM OTHP_Y1 o
                 JOIN EHIS_Y1 e
                  ON e.OthpPartyEmpl_IDNO = o.OtherParty_IDNO
                     AND e.EndEmployment_DATE >= @Ld_Today_DATE
                     AND e.Status_CODE = @Lc_Yes_INDC
                 JOIN CMEM_Y1 d
                  ON d.MemberMci_IDNO = e.MemberMci_IDNO
                     AND d.Case_IDNO = @An_Case_IDNO
                     AND d.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE, @Lc_CaseRelationshipNcp_CODE)
                     AND d.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
           WHERE o.EndValidity_DATE = @Ld_High_DATE
             AND o.TypeOthp_CODE = @Ac_TypeOthp_CODE
             AND (o.TypeOthp_CODE != @Lc_TypeOthpMilitary_CODE 
					OR (o.TypeOthp_CODE = @Lc_TypeOthpMilitary_CODE
						AND d.CaseRelationship_CODE = @Lc_CaseRelationshipNcp_CODE
					   ) 
				 )
		) AS x
   WHERE x.rn BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB;
 END; --END OF OTHP_RETRIEVE_S105


GO
