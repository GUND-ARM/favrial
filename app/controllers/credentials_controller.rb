# FIXME: credentialsってコントローラいらなくない？要検討
class CredentialsController < ApplicationController
  #before_action :set_credential, only: %i[ show edit update destroy ]
  before_action :set_credential, only: %i[ show ]

  ## GET /credentials or /credentials.json
  #def index
  #  @credentials = Credential.all
  #end

  ## GET /credentials/1 or /credentials/1.json
  #def show
  #end

  ## GET /credentials/new
  #def new
  #  @credential = Credential.new
  #end

  ## GET /credentials/1/edit
  #def edit
  #end

  ## POST /credentials or /credentials.json
  #def create
  #  #@credential = Credential.new(credential_params)
  #  @credential = Credential.from_auth_hash(auth_hash)

  #  respond_to do |format|
  #    if @credential.save
  #      format.html { redirect_to credential_url(@credential), notice: "Credential was successfully created." }
  #      #format.json { render :show, status: :created, location: @credential }
  #    else
  #      format.html { render :new, status: :unprocessable_entity }
  #      #format.json { render json: @credential.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  ## PATCH/PUT /credentials/1 or /credentials/1.json
  #def update
  #  respond_to do |format|
  #    if @credential.update(credential_params)
  #      format.html { redirect_to credential_url(@credential), notice: "Credential was successfully updated." }
  #      format.json { render :show, status: :ok, location: @credential }
  #    else
  #      format.html { render :edit, status: :unprocessable_entity }
  #      format.json { render json: @credential.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  ## DELETE /credentials/1 or /credentials/1.json
  #def destroy
  #  @credential.destroy

  #  respond_to do |format|
  #    format.html { redirect_to credentials_url, notice: "Credential was successfully destroyed." }
  #    format.json { head :no_content }
  #  end
  #end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_credential
      @credential = Credential.find(params[:id])
    end

    ## Only allow a list of trusted parameters through.
    #def credential_params
    #  params.require(:credential).permit(:token, :expires_at, :expires)
    #end

    def auth_hash
      request.env['omniauth.auth']
    end
end
