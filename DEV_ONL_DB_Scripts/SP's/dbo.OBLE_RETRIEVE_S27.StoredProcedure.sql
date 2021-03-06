/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S27]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S27] (
 @An_MemberMciSecondary_IDNO	NUMERIC(10,0),
 @Ai_Count_QNTY					INT	 OUTPUT
 )
AS

/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S27
 *     DESCRIPTION       : Retrieve the count of records from Obligation table for Unique number assigned by the system to the participant (This is the ID value that will be searched and replaced by the primary member ID in all the tables that have this member ID as a column) with Open (O) Obligation (i.e., Current Date greater than Obligation Begin Date and less than Obligation End Date). 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 20-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
  BEGIN

     SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_Current_DATE	DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
  		  @Li_Zero_NUMB		SMALLINT = 0,	
   		  @Ld_High_DATE		DATE = '12/31/9999';
        
  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM OBLE_Y1 os
   WHERE os.MemberMci_IDNO = @An_MemberMciSecondary_IDNO  
     AND os.EndValidity_DATE = @Ld_High_DATE 
     AND (@Ld_Current_DATE BETWEEN os.BeginObligation_DATE AND os.EndObligation_DATE
           OR os.ExpectToPay_AMNT > @Li_Zero_NUMB);

END; --END OF OBLE_RETRIEVE_S27 


GO
