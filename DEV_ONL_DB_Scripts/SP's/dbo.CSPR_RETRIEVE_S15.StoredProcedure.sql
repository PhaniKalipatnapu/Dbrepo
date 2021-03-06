/****** Object:  StoredProcedure [dbo].[CSPR_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
     
CREATE PROCEDURE 
	[dbo].[CSPR_RETRIEVE_S15] 
		(   
     		@An_Case_IDNO		 NUMERIC(6,0)               
     	)  
AS  
 
/*  
 *     PROCEDURE NAME    : CSPR_RETRIEVE_S15  
 *     DESCRIPTION       : To Retrive Respondent Name for Search filter in ICOR View Intergovernmental Correspondence History Screen Function.       
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-SEP-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1   
*/  
BEGIN  
  
      DECLARE  
         @Ld_High_DATE 			DATE= '12/31/9999',
         @Lc_RelationshipA_CODE CHAR(1)='A',
         @Lc_RelationshipC_CODE CHAR(1)='C',
         @Lc_RelationshipP_CODE CHAR(1)='P',
         @Li_One_NUMB           SMALLINT = 1;
          
   SELECT DISTINCT RespondentMci_IDNO,
             D.First_NAME,
             D.Middle_NAME,
             D.Last_NAME,
             D.Suffix_NAME 
      FROM CSPR_Y1 c  LEFT OUTER JOIN DEMO_Y1 d ON (c.RespondentMci_IDNO=d.MemberMci_IDNO)
      WHERE   
         c.Case_IDNO = @An_Case_IDNO AND   
         c.EndValidity_DATE = @Ld_High_DATE AND
         c.RespondentMci_IDNO <> 0
   UNION
   SELECT DISTINCT c2.MemberMci_IDNO, c2.First_NAME, c2.Middle_NAME, c2.Last_NAME,
       c2.Suffix_NAME
   FROM CTHB_Y1 c1
   JOIN
   	CNCB_Y1 c2
    ON c1.TransHeader_IDNO = c2.TransHeader_IDNO
     AND c1.Transaction_DATE = c2.Transaction_DATE
     AND c1.IVDOutOfStateFips_CODE = c2.IVDOutOfStateFips_CODE
     WHERE c1.Case_IDNO = @An_Case_IDNO         
  UNION 
  SELECT    DISTINCT c.MemberMci_IDNO, 
          c.First_NAME, 
          c.Middle_NAME, 
          c.Last_NAME, 
          c.Suffix_NAME       
          FROM (SELECT c2.MemberMci_IDNO, c2.First_NAME, c2.Middle_NAME, c2.Last_NAME,           
                       Suffix_NAME,                                                  
                       ROW_NUMBER () OVER (PARTITION BY c2.relationship_CODE ORDER BY c2.Blockseq_NUMB DESC)              
                                                                AS OrderBlockseq_NUMB
                  FROM CTHB_Y1 c1
                  JOIN
                  	 CPTB_Y1 c2                                                      
                 ON c1.TransHeader_IDNO = c2.TransHeader_IDNO
                    AND c1.Transaction_DATE = c2.Transaction_DATE
                    AND c1.IVDOutOfStateFips_CODE = c2.IVDOutOfStateFips_CODE
                 WHERE
                     c2.Relationship_CODE IN (@Lc_RelationshipA_CODE,@Lc_RelationshipC_CODE,@Lc_RelationshipP_CODE)
                    AND c1.Case_IDNO = @An_Case_IDNO  
                    ) c                    
         WHERE OrderBlockseq_NUMB = @Li_One_NUMB;
         
         
                    
END; -- END OF CSPR_RETRIEVE_S15
  

GO
