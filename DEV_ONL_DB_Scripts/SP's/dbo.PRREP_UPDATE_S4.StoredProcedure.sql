/****** Object:  StoredProcedure [dbo].[PRREP_UPDATE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PRREP_UPDATE_S4] (  

		@Ac_Session_ID					CHAR(30),
		@Ac_BackOut_INDC				CHAR(1),
		@Ac_RePost_INDC					CHAR(1),
		@Ac_Refund_INDC					CHAR(1),
		@An_RepostedPayorMci_IDNO		NUMERIC(10,0),
		@An_CasePayorMCIReposted_IDNO	NUMERIC(10,0),
		@An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0)		
		)              
AS

/*
 *     PROCEDURE NAME    : PRREP_UPDATE_S4
 *     DESCRIPTION       : This procedure updates the BackOut, RePost, Refund, Refund indicators and reposted payor, reposted casepayor IDs in PRREP_Y1 table for the Session_ID.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 25-NOV-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
		
	  DECLARE @Lc_Space_TEXT  CHAR(1) = ' ';
	
	   UPDATE PRREP_Y1
		  SET BackOut_INDC				= ISNULL (@Ac_BackOut_INDC, @Lc_Space_TEXT),
		  	  RePost_INDC				= ISNULL (@Ac_RePost_INDC, @Lc_Space_TEXT),
			  Refund_INDC				= ISNULL (@Ac_Refund_INDC , @Lc_Space_TEXT),
			  RepostedPayorMci_IDNO		= ISNULL (@An_RepostedPayorMci_IDNO ,0),
			  CasePayorMCIReposted_IDNO = ISNULL (@An_CasePayorMCIReposted_IDNO, 0)
	    WHERE Session_ID			   = @Ac_Session_ID
	      AND EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB ;
	    
	  
      DECLARE @Ln_RowsAffected_NUMB	NUMERIC(10);
      
          SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
                 
       SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
			
END; -- END OF PRREP_UPDATE_S4


GO
