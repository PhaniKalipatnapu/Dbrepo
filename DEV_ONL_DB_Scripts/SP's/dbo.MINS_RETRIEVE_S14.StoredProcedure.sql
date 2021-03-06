/****** Object:  StoredProcedure [dbo].[MINS_RETRIEVE_S14]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MINS_RETRIEVE_S14] (
 @An_MemberMci_IDNO        NUMERIC(10,0),  
 @An_OthpInsurance_IDNO    NUMERIC(9,0) ,  
 @Ac_InsuranceGroupNo_TEXT CHAR(25)		,  
 @Ac_PolicyInsNo_TEXT      CHAR(20)		,
 @Ac_Exists_INDC		   CHAR(1) OUTPUT
 )
AS
/*
 *     PROCEDURE NAME    : MINS_RETRIEVE_S14
 *     DESCRIPTION       : Retrieves the value as 'Y' if the given member exists in MemberInsurance table
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 11-OCT-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
	BEGIN
		
		DECLARE	@Lc_Space_TEXT	CHAR(1) = ' ',
			@Ld_High_DATE		DATE = '12/31/9999',
			@Lc_Yes_INDC		CHAR(1)='Y',
			@Lc_No_INDC			CHAR(1)='N';

			SET @Ac_Exists_INDC = @Lc_No_INDC;
		
		SELECT TOP 1 @Ac_Exists_INDC  = @Lc_Yes_INDC
               FROM MINS_Y1 m 
              WHERE m.MemberMci_IDNO = @An_MemberMci_IDNO  
                AND m.OthpInsurance_IDNO = @An_OthpInsurance_IDNO  
                AND m.InsuranceGroupNo_TEXT = ISNULL(@Ac_InsuranceGroupNo_TEXT, @Lc_Space_TEXT)  
                AND m.PolicyInsNo_TEXT = ISNULL(@Ac_PolicyInsNo_TEXT, @Lc_Space_TEXT)  
                AND m.EndValidity_DATE = @Ld_High_DATE;
                
                
END	-- End of MINS_RETRIEVE_S14 


GO
