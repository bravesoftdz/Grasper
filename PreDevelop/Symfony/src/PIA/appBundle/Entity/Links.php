<?php

namespace PIA\appBundle\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * Links
 */
class Links
{
    /**
     * @var integer
     */
    private $id;

    /**
     * @var integer
     */
    private $level;

    /**
     * @var integer
     */
    private $num;

    /**
     * @var string
     */
    private $link;

    /**
     * @var string
     */
    private $linkHash;

    /**
     * @var boolean
     */
    private $handled;

    /**
     * @var \PIA\appBundle\Entity\Jobs
     */
    private $job;


    /**
     * Get id
     *
     * @return integer 
     */
    public function getId()
    {
        return $this->id;
    }

    /**
     * Set level
     *
     * @param integer $level
     * @return Links
     */
    public function setLevel($level)
    {
        $this->level = $level;

        return $this;
    }

    /**
     * Get level
     *
     * @return integer 
     */
    public function getLevel()
    {
        return $this->level;
    }

    /**
     * Set num
     *
     * @param integer $num
     * @return Links
     */
    public function setNum($num)
    {
        $this->num = $num;

        return $this;
    }

    /**
     * Get num
     *
     * @return integer 
     */
    public function getNum()
    {
        return $this->num;
    }

    /**
     * Set link
     *
     * @param string $link
     * @return Links
     */
    public function setLink($link)
    {
        $this->link = $link;

        return $this;
    }

    /**
     * Get link
     *
     * @return string 
     */
    public function getLink()
    {
        return $this->link;
    }

    /**
     * Set linkHash
     *
     * @param string $linkHash
     * @return Links
     */
    public function setLinkHash($linkHash)
    {
        $this->linkHash = $linkHash;

        return $this;
    }

    /**
     * Get linkHash
     *
     * @return string 
     */
    public function getLinkHash()
    {
        return $this->linkHash;
    }

    /**
     * Set handled
     *
     * @param boolean $handled
     * @return Links
     */
    public function setHandled($handled)
    {
        $this->handled = $handled;

        return $this;
    }

    /**
     * Get handled
     *
     * @return boolean 
     */
    public function getHandled()
    {
        return $this->handled;
    }

    /**
     * Set job
     *
     * @param \PIA\appBundle\Entity\Jobs $job
     * @return Links
     */
    public function setJob(\PIA\appBundle\Entity\Jobs $job = null)
    {
        $this->job = $job;

        return $this;
    }

    /**
     * Get job
     *
     * @return \PIA\appBundle\Entity\Jobs 
     */
    public function getJob()
    {
        return $this->job;
    }
}
