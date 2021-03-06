/****** Object:  StoredProcedure [dbo].[AHIS_RETRIEVE_S26]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AHIS_RETRIEVE_S26] (
 @An_MemberMci_IDNO				NUMERIC(10),
 @An_MemberMciSecondary_IDNO	NUMERIC(10),
 @Ai_Count_QNTY		 			INT	 OUTPUT
 )                                                      
AS

/*
 *     PROCEDURE NAME    : AHIS_RETRIEVE_S26
 *     DESCRIPTION       : Retrieve the count of records from Address Details table for Unique number assigned by the system to the participant (This is the ID value that will replace with the secondary DCN in all the tables that have this member ID) and Unique number assigned by the system to the participant (This is the ID value that will be searched and replaced by the primary member ID in all the tables that have this member ID as a column) with Address Verification Status equal to CONFIRMED GOOD (Y) and Open Address (i.e., Current Date is greater than Date from which the Participant started staying at this Address and less than Date up to which the Participant stayed at this Address) for both the Members. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 19-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 BEGIN

      SET @Ai_Count_QNTY = NULL;

	  DECLARE	@Lc_StatusGood_CODE		CHAR(1) = 'Y',
				@Lc_TypeAddressC_CODE	CHAR(1) = 'C',
				@Ld_Current_DATE		DATE	= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
        
      SELECT @Ai_Count_QNTY = COUNT(1)
        FROM AHIS_Y1 a 
             JOIN
             AHIS_Y1 b
          ON a.TypeAddress_CODE = b.TypeAddress_CODE
         AND b.TypeAddress_CODE != @Lc_TypeAddressC_CODE
       WHERE @Ld_Current_DATE BETWEEN a.Begin_DATE AND a.End_DATE 
         AND @Ld_Current_DATE BETWEEN b.Begin_DATE AND b.End_DATE 
         AND a.Status_CODE = @Lc_StatusGood_CODE
         AND b.Status_CODE = @Lc_StatusGood_CODE 
         AND a.MemberMci_IDNO = @An_MemberMci_IDNO 
         AND b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
                                
END; --END OF AHIS_RETRIEVE_S26 


GO
