/****** Object:  StoredProcedure [dbo].[MMRG_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MMRG_RETRIEVE_S8] (
 @An_MemberMciPrimary_IDNO	NUMERIC(10,0),
 @Ai_RowFrom_NUMB          	INT = 1 ,
 @Ai_RowTo_NUMB             INT = 10
 )
AS

/*
 *     PROCEDURE NAME    : MMRG_RETRIEVE_S8
 *     DESCRIPTION       : Retrieve Unique number assigned by the system to the participant (This is the ID value that will replace with the secondary DCN in all the tables that have this member ID), Derived Primary Member Name and SSN from Primary Member DCN, Derived Secondary Member Name and SSN from Secondary Member DCN, Unique number assigned by the system to the participant (This is the ID value that will be searched and replaced by the primary member ID in all the tables that have this member ID as a column) and Unique Sequence Number that will be generated for any given Transaction on the Table from Member Merge table for Unique number assigned by the system to the participant (This is the ID value that will replace with the secondary DCN in all the tables that have this member ID) and status of the merge equal to PENDING (P). 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 23-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
 BEGIN

   DECLARE @Ld_High_DATE 				DATE = '12/31/9999', 
       	   @Lc_StatusMergePending_CODE	CHAR(1) = 'P';
        
   SELECT Y.MemberMciPrimary_IDNO , 
   		  B.Last_NAME AS PrimaryLastName_TEXT,
   		  B.First_NAME AS PrimaryFirstName_TEXT,
   		  B.Middle_NAME AS PrimaryMiddleName_TEXT,
   		  B.Suffix_NAME AS PrimarySuffixName_TEXT,   		  
   	      B.MemberSsn_NUMB AS MemberPrimarySsn_NUMB,
    	  Y.MemberMciSecondary_IDNO , 
    	  C.Last_NAME AS SecondaryLastName_TEXT,
   		  C.First_NAME AS SecondaryFirstName_TEXT,
   		  C.Middle_NAME AS SecondaryMiddleName_TEXT,
   		  C.Suffix_NAME AS SecondarySuffixName_TEXT,   		  
   		  C.MemberSsn_NUMB AS MemberSecondarySsn_NUMB,
    	  Y.TransactionEventSeq_NUMB , 
          Y.RowCount_NUMB  
    FROM (
           SELECT X.MemberMciPrimary_IDNO, 
                  X.MemberMciSecondary_IDNO, 
                  X.TransactionEventSeq_NUMB, 
                  X.RowCount_NUMB, 
                  X.ORD_ROWNUM 
           FROM (
                 SELECT a.MemberMciPrimary_IDNO, 
                     	a.MemberMciSecondary_IDNO, 
                     	a.TransactionEventSeq_NUMB, 
                     	COUNT(1) OVER() AS RowCount_NUMB, 
                     	ROW_NUMBER() OVER( ORDER BY a.MemberMciPrimary_IDNO) AS ORD_ROWNUM
                   FROM MMRG_Y1 a
                  WHERE a.MemberMciPrimary_IDNO = ISNULL(@An_MemberMciPrimary_IDNO, a.MemberMciPrimary_IDNO) 
                    AND a.EndValidity_DATE = @Ld_High_DATE 
                    AND a.StatusMerge_CODE = @Lc_StatusMergePending_CODE
               )  AS X
            WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB
         )  AS Y
            LEFT OUTER JOIN DEMO_Y1 B 
           ON (Y.MemberMciPrimary_IDNO= B.MemberMci_IDNO)
            LEFT OUTER JOIN DEMO_Y1 C
            ON (Y.MemberMciSecondary_IDNO=C.MemberMci_IDNO)
    WHERE Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB
ORDER BY ORD_ROWNUM;

END; --END OF MMRG_RETRIEVE_S8


GO
