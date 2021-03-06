/****** Object:  StoredProcedure [dbo].[PRDE_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PRDE_RETRIEVE_S2](
 @An_CaseWelfare_IDNO             NUMERIC(10,0),
 @An_AgSequence_NUMB              NUMERIC(4,0),
 @An_TransactionEventSeq_NUMB     NUMERIC(19,0),
 @Ai_Record_NUMB                  INT,
 @Ac_CaseRelationship_CODE        CHAR(1)       OUTPUT,
 @Ac_First_NAME                   CHAR(16)      OUTPUT,
 @Ac_Middle_NAME                  CHAR(20)      OUTPUT,
 @Ac_Last_NAME                    CHAR(20)      OUTPUT,
 @Ac_Suffix_NAME                  CHAR(4)       OUTPUT,          
 @Ad_Birth_DATE                   DATE          OUTPUT,          
 @An_MemberSsn_NUMB               NUMERIC(9,0)  OUTPUT,
 @Ac_MemberSex_CODE               CHAR(1)       OUTPUT,  
 @Ac_Race_CODE                    CHAR(2)       OUTPUT,            
 @Ac_CpRelationshipToChild_CODE   CHAR(3)       OUTPUT,
 @Ac_NcpRelationshipToChild_CODE  CHAR(3)       OUTPUT,
 @As_Line1_ADDR                   VARCHAR(50)   OUTPUT,
 @As_Line2_ADDR                   VARCHAR(50)   OUTPUT,
 @Ac_City_ADDR                    CHAR(28)      OUTPUT,
 @Ac_State_ADDR                   CHAR(2)       OUTPUT,
 @Ac_Zip_ADDR                     CHAR(15)      OUTPUT,
 @An_RowCount_NUMB                NUMERIC(6,0)  OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : PRDE_RETRIEVE_S2
 *     DESCRIPTION       : Retrieves the pending members details for the given IVA Case ID for the Pending Case and Record number.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-FEB-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

    SELECT @Ac_CaseRelationship_CODE        =NULL,
		   @Ac_First_NAME                   =NULL,
		   @Ac_Middle_NAME                  =NULL,
		   @Ac_Last_NAME                    =NULL,
		   @Ac_Suffix_NAME                  =NULL,
		   @Ad_Birth_DATE                   =NULL,
		   @An_MemberSsn_NUMB               =NULL,
		   @Ac_MemberSex_CODE               =NULL,
		   @Ac_Race_CODE                    =NULL,
		   @Ac_CpRelationshipToChild_CODE   =NULL,
		   @Ac_NcpRelationshipToChild_CODE  =NULL,
		   @As_Line1_ADDR                   =NULL,
		   @As_Line2_ADDR                   =NULL,
		   @Ac_City_ADDR                    =NULL,
		   @Ac_State_ADDR                   =NULL,
		   @Ac_Zip_ADDR                     =NULL,
		   @An_RowCount_NUMB                =NULL;

--13681 -- BATCH_FIN_IVA_UPDATES failed while inserting record into CPDR -- Start
	
	SELECT @Ac_CaseRelationship_CODE       =  X.CaseRelationship_CODE,      
		   @Ac_First_NAME                  =  X.First_NAME,                 
		   @Ac_Middle_NAME                 =  X.Middle_NAME,                
		   @Ac_Last_NAME                   =  X.Last_NAME,                  
		   @Ac_Suffix_NAME                 =  X.Suffix_NAME,                
		   @Ad_Birth_DATE                  =  X.Birth_DATE,                 
		   @An_MemberSsn_NUMB              =  X.MemberSsn_NUMB,             
		   @Ac_MemberSex_CODE              =  X.MemberSex_CODE,             
		   @Ac_Race_CODE                   =  X.Race_CODE,                  
		   @Ac_CpRelationshipToChild_CODE  =  X.CpRelationshipToChild_CODE, 
		   @Ac_NcpRelationshipToChild_CODE =  X.NcpRelationshipToChild_CODE,
		   @As_Line1_ADDR                  =  X.Line1_ADDR,                 
		   @As_Line2_ADDR                  =  X.Line2_ADDR,                 
		   @Ac_City_ADDR                   =  X.City_ADDR,                  
		   @Ac_State_ADDR                  =  X.State_ADDR,                 
		   @Ac_Zip_ADDR                    =  X.Zip_ADDR,   
		   @An_RowCount_NUMB               =  X.RowCount_NUMB    
    FROM(SELECT d.CaseRelationship_CODE,
			d.First_NAME,
			d.Middle_NAME,
			d.Last_NAME,
			d.Suffix_NAME,
			d.Birth_DATE,
			d.MemberSsn_NUMB,
			d.MemberSex_CODE,
			d.Race_CODE,
			d.CpRelationshipToChild_CODE,
			d.NcpRelationshipToChild_CODE,
			a.Line1_ADDR,
			a.Line2_ADDR,
			a.City_ADDR,
			a.State_ADDR,
			a.Zip_ADDR,
			ROW_NUMBER() OVER(
		                  ORDER BY d.CaseRelationship_CODE ASC) AS Rec_NUMB, 
		    COUNT(1) OVER() AS RowCount_NUMB
		  FROM PRCA_Y1 c,
				PRDE_Y1 d
				LEFT OUTER JOIN PRAH_Y1 a 
				ON a.CaseWelfare_IDNO = d.CaseWelfare_IDNO
				AND a.AgSequence_NUMB = d.AgSequence_NUMB
				AND a.ReferralReceived_DATE = d.ReferralReceived_DATE
				AND a.MemberMci_IDNO = d.MemberMci_IDNO
			WHERE c.CaseWelfare_IDNO = d.CaseWelfare_IDNO
			AND c.AgSequence_NUMB = d.AgSequence_NUMB
			AND c.ReferralReceived_DATE = d.ReferralReceived_DATE
			AND c.TransactionEventSeq_NUMB = d.TransactionEventSeq_NUMB
			AND c.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
			AND c.AgSequence_NUMB = @An_AgSequence_NUMB
			AND c.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB)  AS X
	WHERE X.Rec_NUMB = @Ai_Record_NUMB;
	
--13681 -- BATCH_FIN_IVA_UPDATES failed while inserting record into CPDR -- End
	     
END; --End of PRDE_RETRIEVE_S2


GO
